#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIVE_BUILD_DIR="$PROJECT_ROOT/live-build"
ARTIFACTS_DIR="$PROJECT_ROOT/artifacts"
OWNER_UID="$(id -u)"
OWNER_GID="$(id -g)"

if [ "$OWNER_UID" -eq 0 ]; then
  echo "ERROR: Do not run this script as root or with sudo."
  echo "Run it as your normal user; the script uses sudo only for live-build steps."
  exit 1
fi

# No matter how this script exits -- success, error, or interruption -- return
# the checkout to the developer user. live-build and fakeroot can leave files
# owned by root or nobody in live-build/ and artifacts/.
repair_project_ownership() {
  FOREIGN_OWNED="$(find "$PROJECT_ROOT" -xdev ! -user "$OWNER_UID" -print -quit 2>/dev/null || true)"
  if [ -n "$FOREIGN_OWNED" ]; then
    sudo find "$PROJECT_ROOT" -xdev ! -user "$OWNER_UID" -exec chown -h "$OWNER_UID:$OWNER_GID" {} + 2>/dev/null || true
  fi
}

verify_project_ownership() {
  FOREIGN_OWNED="$(find "$PROJECT_ROOT" -xdev ! -user "$OWNER_UID" -print -quit 2>/dev/null || true)"
  if [ -n "$FOREIGN_OWNED" ]; then
    echo
    echo "WARNING: Project tree still contains files not owned by $(id -un):"
    find "$PROJECT_ROOT" -xdev ! -user "$OWNER_UID" -printf '  %p (%u:%g)\n' 2>/dev/null | head -n 20 || true
    echo "Git may fail until ownership is repaired."
  fi
}

cleanup_on_exit() {
  repair_project_ownership
  verify_project_ownership
}

trap cleanup_on_exit EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

VERSION_FILE="$PROJECT_ROOT/VERSION"
VERSION="dev"

if [ -f "$VERSION_FILE" ]; then
  VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
fi

TIMESTAMP="$(date +%Y%m%d-%H%M)"
ISO_NAME="anemone-os-${VERSION}-${TIMESTAMP}.iso"

echo "== Anemone OS build =="
echo "Project root:    $PROJECT_ROOT"
echo "Live-build dir:  $LIVE_BUILD_DIR"
echo "Artifacts dir:   $ARTIFACTS_DIR"
echo "Version:         $VERSION"
echo

# --- Self-healing ownership repair ---
# Repair leftovers from previous builds before Git or shell operations need to
# write there. This covers root-owned live-build state and fakeroot/nobody ISO
# artifacts without assuming the same username on every development machine.
FOREIGN_OWNED_COUNT="$(find "$PROJECT_ROOT" -xdev ! -user "$OWNER_UID" 2>/dev/null | wc -l)"
if [ "$FOREIGN_OWNED_COUNT" -gt 0 ]; then
  echo "Found $FOREIGN_OWNED_COUNT file(s) not owned by $(id -un) from a previous run."
  echo "Reclaiming ownership for $(id -un)..."
  repair_project_ownership
  REMAINING_FOREIGN_OWNED="$(find "$PROJECT_ROOT" -xdev ! -user "$OWNER_UID" -print -quit 2>/dev/null || true)"
  if [ -n "$REMAINING_FOREIGN_OWNED" ]; then
    echo "ERROR: Could not repair ownership under:"
    echo "  $PROJECT_ROOT"
    echo "First remaining path:"
    echo "  $REMAINING_FOREIGN_OWNED"
    exit 1
  else
    echo "Ownership repaired."
    echo
  fi
fi

command -v lb >/dev/null 2>&1 || {
  echo "ERROR: live-build is not installed."
  echo "Install with:"
  echo "  sudo apt install live-build"
  exit 1
}

if [ ! -d "$LIVE_BUILD_DIR" ]; then
  echo "ERROR: Missing live-build directory: $LIVE_BUILD_DIR"
  exit 1
fi

if [ ! -d "$LIVE_BUILD_DIR/config" ]; then
  echo "ERROR: Missing live-build config directory: $LIVE_BUILD_DIR/config"
  exit 1
fi

mkdir -p "$ARTIFACTS_DIR"

echo "Checking for forbidden production sources..."

if [ -f "$LIVE_BUILD_DIR/config/archives/sid.list.chroot" ]; then
  echo "ERROR: Debian Sid repository is enabled:"
  echo "  $LIVE_BUILD_DIR/config/archives/sid.list.chroot"
  echo
  echo "For Anemone OS v1 production baseline, Sid must be disabled."
  echo "Rename it to:"
  echo "  sid.list.chroot.disabled"
  exit 1
fi

echo "Checking git working tree..."

if command -v git >/dev/null 2>&1 && git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if ! git -C "$PROJECT_ROOT" diff --quiet || ! git -C "$PROJECT_ROOT" diff --cached --quiet; then
    echo "WARNING: Git working tree has uncommitted changes."
    echo "This build may not be reproducible from a clean checkout."
    echo
  fi

  GIT_COMMIT="$(git -C "$PROJECT_ROOT" rev-parse --short HEAD)"
else
  GIT_COMMIT="nogit"
fi

echo "Git commit:      $GIT_COMMIT"
echo

BUILD_STAMP="${TIMESTAMP} / ${GIT_COMMIT}"
echo "Build stamp:     $BUILD_STAMP"

GRUB_STAMP_FILE="$LIVE_BUILD_DIR/config/includes.binary/boot/grub/anemone-build-stamp.cfg"
mkdir -p "$(dirname "$GRUB_STAMP_FILE")"
cat > "$GRUB_STAMP_FILE" <<STAMP
set anemone_build_stamp="${BUILD_STAMP}"
STAMP

echo "GRUB stamp file written: $GRUB_STAMP_FILE"
echo

cd "$LIVE_BUILD_DIR"

echo "Cleaning previous live-build state (full reset)..."
echo "This removes cache/, chroot/, .build/, and binary/ — every build starts from scratch."

sudo rm -rf \
  "$LIVE_BUILD_DIR/cache" \
  "$LIVE_BUILD_DIR/chroot" \
  "$LIVE_BUILD_DIR/.build" \
  "$LIVE_BUILD_DIR/binary"

rm -f \
  "$LIVE_BUILD_DIR/chroot.files" \
  "$LIVE_BUILD_DIR/chroot.installed_tmp_pkgs" \
  "$LIVE_BUILD_DIR/chroot.packages.install" \
  "$LIVE_BUILD_DIR/chroot.packages.live" \
  "$LIVE_BUILD_DIR/binary.modified_timestamps" \
  "$LIVE_BUILD_DIR/installer_firmware_details.txt"

sudo lb clean --purge

echo "Clean complete — no cached layers remain."
echo

echo "Configuring live-build..."
sudo lb config

echo "Starting live-build..."
sudo lb build

echo "Searching for generated ISO..."

ISO_PATH="$(find "$LIVE_BUILD_DIR" -maxdepth 1 -type f -name '*.iso' | sort | tail -n 1 || true)"

if [ -z "$ISO_PATH" ]; then
  echo "ERROR: Build completed, but no ISO was found in:"
  echo "  $LIVE_BUILD_DIR"
  exit 1
fi

FINAL_ISO="$ARTIFACTS_DIR/$ISO_NAME"

echo "Moving ISO:"
echo "  from: $ISO_PATH"
echo "  to:   $FINAL_ISO"

mv "$ISO_PATH" "$FINAL_ISO"

ln -sfn "$(basename "$FINAL_ISO")" "$ARTIFACTS_DIR/anemone-os-latest.iso"

cat > "$ARTIFACTS_DIR/${ISO_NAME%.iso}.build-info.txt" <<INFO
Anemone OS build information

Version:      $VERSION
Git commit:   $GIT_COMMIT
Built at:     $(date --iso-8601=seconds)
Host:         $(hostname)
Live-build:   $(lb --version 2>/dev/null || echo unknown)
ISO:          $(basename "$FINAL_ISO")
INFO

echo
echo "Build complete."
echo "ISO:"
echo "  $FINAL_ISO"
echo
echo "Latest symlink:"
echo "  $ARTIFACTS_DIR/anemone-os-latest.iso"

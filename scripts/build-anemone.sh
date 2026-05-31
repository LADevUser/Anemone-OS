#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIVE_BUILD_DIR="$PROJECT_ROOT/live-build"
ARTIFACTS_DIR="$PROJECT_ROOT/artifacts"

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

cd "$LIVE_BUILD_DIR"

echo "Cleaning previous live-build state..."
sudo lb clean --purge || true

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

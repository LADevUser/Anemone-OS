#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIVE_BUILD_DIR="$PROJECT_ROOT/live-build"
OWNER_UID="$(id -u)"
OWNER_GID="$(id -g)"

if [ "$OWNER_UID" -eq 0 ]; then
  echo "ERROR: Do not run this script as root or with sudo."
  exit 1
fi

repair_project_ownership() {
  FOREIGN_OWNED="$(find "$PROJECT_ROOT" -xdev ! -user "$OWNER_UID" -print -quit 2>/dev/null || true)"
  if [ -n "$FOREIGN_OWNED" ]; then
    sudo find "$PROJECT_ROOT" -xdev ! -user "$OWNER_UID" -exec chown -h "$OWNER_UID:$OWNER_GID" {} + 2>/dev/null || true
  fi
}

cleanup_on_exit() {
  repair_project_ownership
  FOREIGN_OWNED="$(find "$PROJECT_ROOT" -xdev ! -user "$OWNER_UID" -print -quit 2>/dev/null || true)"
  if [ -n "$FOREIGN_OWNED" ]; then
    echo "WARNING: Project tree still contains files not owned by $(id -un)."
    find "$PROJECT_ROOT" -xdev ! -user "$OWNER_UID" -printf '  %p (%u:%g)\n' 2>/dev/null | head -n 20 || true
  fi
}

trap cleanup_on_exit EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

repair_project_ownership

cd "$LIVE_BUILD_DIR"
sudo lb clean --purge || true

sudo rm -rf \
  "$LIVE_BUILD_DIR/.build" \
  "$LIVE_BUILD_DIR/cache" \
  "$LIVE_BUILD_DIR/chroot" \
  "$LIVE_BUILD_DIR/binary"

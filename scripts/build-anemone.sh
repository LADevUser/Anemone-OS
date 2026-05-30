#!/bin/bash

set -e

# ===== CONFIG =====
DIST="trixie"
ARCH="amd64"
NAME="anemone"

VERSION_FILE="VERSION"
BUILD_DIR="builds"

# ===== INIT =====
mkdir -p "$BUILD_DIR"

# Om VERSION saknas → skapa
if [ ! -f "$VERSION_FILE" ]; then
    echo "v1.0.0" > "$VERSION_FILE"
fi

VERSION=$(cat "$VERSION_FILE")

# Buildnummer (auto increment)
BUILD_NUMBER_FILE="$BUILD_DIR/.build_number"

if [ ! -f "$BUILD_NUMBER_FILE" ]; then
    echo "0" > "$BUILD_NUMBER_FILE"
fi

BUILD_NUMBER=$(cat "$BUILD_NUMBER_FILE")
BUILD_NUMBER=$((BUILD_NUMBER + 1))
echo "$BUILD_NUMBER" > "$BUILD_NUMBER_FILE"

DATE=$(date +%Y%m%d-%H%M)

OUTPUT="${NAME}-${VERSION}-b${BUILD_NUMBER}-${DATE}.iso"
LOG="${BUILD_DIR}/build-${VERSION}-b${BUILD_NUMBER}-${DATE}.log"

echo "🌿 Building Anemone Linux..."
echo "Version: $VERSION"
echo "Build: $BUILD_NUMBER"
echo "Date: $DATE"
echo "----------------------------------"

# ===== CLEAN =====
echo "🧹 Cleaning..."
sudo lb clean --purge

rm -f wget-log*
rm -f *.iso
rm -f build.log

# ===== CONFIG =====
echo "⚙️ Configuring..."
sudo lb config \
  --distribution "$DIST" \
  --architectures "$ARCH" \
  --archive-areas "main contrib non-free non-free-firmware" \
  --debian-installer live \
  --bootappend-live "boot=live components quiet splash systemd.show_status=false"

# ===== BUILD =====
echo "🏗️ Building..."
sudo lb build 2>&1 | tee "$LOG"

# ===== FIND ISO =====
ISO_FOUND=$(ls live-image-*.iso 2>/dev/null | head -n 1 || true)

if [ -z "$ISO_FOUND" ]; then
    echo "❌ No ISO found! Build failed."
    exit 1
fi

# ===== MOVE OUTPUT =====
mv "$ISO_FOUND" "$BUILD_DIR/$OUTPUT"

# ===== LATEST SYMLINK =====
ln -sf "$OUTPUT" "$BUILD_DIR/${NAME}-latest.iso"

echo "----------------------------------"
echo "✅ DONE"
echo "ISO: $BUILD_DIR/$OUTPUT"
echo "LOG: $LOG"
echo "Latest: $BUILD_DIR/${NAME}-latest.iso"

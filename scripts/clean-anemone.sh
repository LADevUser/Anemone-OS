#!/bin/bash

set -e

# Säkerställ att vi är i rätt katalog
if [ ! -d "config" ] || [ ! -d "auto" ]; then
    echo "❌ Detta är inte en live-build katalog!"
    echo "Avbryter för säkerhet."
    exit 1
fi

echo "🧹 Cleaning Anemone project..."

# Ta bort wget-log skräp
echo "Removing wget logs..."
rm -f wget-log*

# Ta bort ISO i ROOT (men INTE builds/)
echo "Removing root ISOs..."
find . -maxdepth 1 -type f -name "*.iso" -delete

# Ta bort live-build artefakter
echo "Removing build artifacts..."
sudo rm -rf binary
sudo rm -rf chroot
sudo rm -rf cache

# local är optional – ta bort bara om den finns
if [ -d "local" ]; then
    sudo rm -rf local
fi

# Metadata
rm -f binary.modified_timestamps
rm -f build.log

echo "✅ Cleanup done!"

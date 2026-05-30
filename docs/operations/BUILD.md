# Build Anemone OS

Anemone OS is built from Debian Trixie using live-build.

## Build from repository

Run from repository root:

    cd live-build
    sudo lb clean --purge
    sudo lb build

## Rule

Generated ISO files, logs, cache and chroot output must not be committed to git.

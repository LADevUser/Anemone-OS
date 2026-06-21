# Build Anemone OS

Anemone OS is built from Debian Trixie using live-build.

## Live ISO credentials

The live image is configured for GNOME autologin when the live-config GDM
component runs successfully.

If a login prompt appears, use:

- username: `anemone`
- password: `anemone`

The live image is a try-it/demo environment. Credentials are intentionally
simple and are only for the live demonstration image.

## Build from repository

Run from repository root:

    cd live-build
    sudo lb clean --purge
    sudo lb build

## Rule

Generated ISO files, logs, cache and chroot output must not be committed to git.

## Validate a booted live session

After booting the live image, run:

    /usr/local/bin/validate-live-baseline.sh

The source copy is maintained at:

    scripts/validate-live-baseline.sh

# Anemone OS

Anemone OS is currently a Debian Trixie based live workstation demo for
stakeholder evaluation. It is intended to boot from USB, start a GNOME desktop,
and demonstrate the first public-sector office workstation baseline.

This is not the final product. The current image is a live demo, not an
installable managed workstation release.

## Current demo scope

The demo image is expected to provide:

- GNOME desktop session
- Firefox ESR
- LibreOffice
- Thunderbird
- PDF viewing
- Printing and scanning foundations
- PipeWire audio stack
- Swedish locale, keyboard, timezone, and regional defaults
- Basic Anemone visual placeholder assets already present in the repository

## Build the ISO

Builds use Debian `live-build`.

Run from the repository root:

```sh
cd live-build
sudo lb clean --purge
sudo lb build
```

Generated ISO files, logs, caches, chroots, and binary output must not be
committed to git.

## Write the ISO to USB

Replace `/dev/sdX` with the target USB device. Do not use a partition such as
`/dev/sdX1`.

```sh
sudo dd if=live-build/live-image-amd64.hybrid.iso of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

Verify the target device before running `dd`; this command overwrites it.

## Live ISO credentials

The live image is configured for GNOME autologin when the live-config GDM
component runs successfully.

If a login prompt appears, use:

- Username: `anemone`
- Password: `anemone`

These credentials are only for the live demonstration image.

## Validate a booted live session

After booting the live image, run:

```sh
/usr/local/bin/validate-live-baseline.sh
```

The same script is stored in the repository at
`scripts/validate-live-baseline.sh`.

## Known limitations

- Installer is disabled. The image is live-USB only for this demo.
- Visual identity is not fully integrated. Existing wallpaper and boot visuals
  are placeholders.
- Production management, enrollment, identity integration, policy management,
  and device compliance are not implemented yet.
- This image must not be treated as a production municipal or government
  workstation baseline until the release gates are completed.

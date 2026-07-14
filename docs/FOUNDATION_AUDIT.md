# Foundation Audit

Date: 2026-07-14

Scope: ownership hygiene, generated-file cleanup, live-build structure, GRUB
theme resources, Plymouth theme resources, hooks, and build documentation.

## Keep

- `scripts/build-anemone.sh`: canonical build entry point.
- `scripts/build-cleanup-anemone.sh`: manual cleanup helper, now guarded against
  root execution and foreign-owned leftovers.
- `scripts/validate-live-baseline.sh` and the copy installed into
  `includes.chroot/usr/local/bin/`: used for validating a booted live session.
- `live-build/config/includes.binary/`: binary-image files that belong on the
  ISO outside the chroot, including GRUB and ISOLINUX resources.
- `live-build/config/includes.chroot/`: target filesystem customizations,
  including Plymouth, branding, defaults, validation, and live user config.
- `live-build/config/bootloaders/`: live-build bootloader templates and GRUB
  theme selection.
- `live-build/config/hooks/live/`: Anemone-specific chroot hooks for dconf,
  live user creation, fuse3 policy, and Plymouth theme activation.
- `live-build/config/hooks/normal/`: live-build-provided symlink hooks plus the
  Anemone Swedish defaults hook.
- `docs/package-snapshots/`: intentionally kept as historical package snapshots,
  separate from generated root-level live-build package manifests.

## Removed

- `live-build/wget-log*`: generated downloader logs from live-build.
- `live-build/chroot.packages.install` and `live-build/chroot.packages.live`:
  generated package manifests. Stable snapshots remain under
  `docs/package-snapshots/`.
- `live-build/binary.modified_timestamps`: generated live-build metadata.
- `artifacts/*.build-info.txt` and old debug log files that were tracked in Git:
  generated build outputs; `artifacts/.gitkeep` remains.
- Root-level `*.pf2` font copies: unused working copies. The GRUB theme keeps
  the font files it actually ships under
  `live-build/config/includes.binary/boot/grub/themes/anemone/`.
- `live-build/config/includes.binary/boot/grub/themes/anemone/tcopy.txt`:
  unused GRUB theme draft. `theme.txt` is the active theme.

## Uncertain

- `live-build/config/hooks/normal/` symlinks to `/usr/share/live/build/hooks/`:
  these look like live-build defaults captured in the project. They are kept
  because removing them may subtly change image reproducibility.
- `live-build/config/hooks/live/0010-*` and `0050-*` symlinks: kept for the same
  reason.
- Empty live-build directories such as `config/archives`, `config/preseed`, and
  `config/includes.*`: likely created by `lb config`. They are harmless but can
  be reconsidered if the project later owns a stricter minimal live-build tree.
- `live-build/config/includes.chroot/usr/share/pixmaps/debian-logo.png`: kept
  because desktop components may still reference the Debian pixmap fallback.
- GRUB font files not referenced directly by `theme.txt` but shipped in the
  theme directory: kept because GRUB font loading can depend on generated font
  names rather than file names.

## Ownership Policy

- Build scripts must be started as the normal developer user.
- Git must never be run with `sudo`.
- Build scripts may use `sudo` only for live-build cleanup, config, and build
  operations.
- On every exit path, including error and interruption, build scripts attempt to
  return all files in the checkout to the invoking developer UID/GID. Symlinks
  are repaired as symlinks, not by following them outside the checkout.
- Before exit, scripts verify whether any files in the checkout are still owned
  by another user and print the first affected paths if repair failed.

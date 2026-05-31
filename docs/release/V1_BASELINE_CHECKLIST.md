# Anemone OS v1 Baseline Checklist

Anemone OS v1 is a Debian Trixie based public-sector office workstation for municipalities, government agencies, and regional public sector organizations.

## Required Baseline

- GNOME core desktop and GDM login are present.
- Firefox ESR is present.
- Thunderbird is present when thick-client email is part of the release scope.
- LibreOffice and GNOME integration are present.
- Evince is present for PDF handling.
- CUPS printing support is present.
- Simple Scan is present.
- PipeWire and WirePlumber audio support is present.
- NetworkManager is present.
- Core fonts and emoji fonts are present.
- Required firmware packages are present.
- Locale and console configuration packages are present.
- Basic support utilities such as `curl`, `wget`, `ca-certificates`, and `gnupg` are present.

## Exclusions

- The default build must not include compiler toolchains, SDKs, or developer Python tooling.
- The default build must not include AWS, Azure, Google, or Meta cloud tooling.
- The default build must not depend on Debian Sid/Unstable.
- The default build must not depend on Microsoft, Amazon, Google, Meta, or other third-party package repositories.
- Legacy FUSE packages must not be installed unless required by a named supported application.

## Release Review

- Review `live-build/config/package-lists/` for developer or cloud packages.
- Review `live-build/config/archives/` for enabled third-party repositories.
- Review `live-build/config/apt/` for disabled security checks.
- Review `live-build/config/hooks/` for network installs and unstable-suite references.
- Review `live-build/config/includes.chroot/` for shell defaults that assume removed developer tools.

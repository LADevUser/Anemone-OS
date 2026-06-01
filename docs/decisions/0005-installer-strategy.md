# ADR 0005: Installer strategy

## Status

Accepted for v1 live baseline.

## Context

Anemone OS must eventually support both live usage and installation to disk.

The current Debian Installer integration blocks the v1 live build because installer-related package resolution still references legacy packages that are not available in the current Debian Trixie baseline.

## Decision

For the first v1 live baseline, Debian Installer is disabled.

The first milestone is a stable bootable live workstation image.

Installer support will be handled as a separate milestone after the live image is stable.

## Consequences

- v1 live baseline can progress without installer-specific dependency issues.
- Installation support remains a required future capability.
- Installer options to evaluate later:
  - Debian Installer
  - Calamares
  - Image-based deployment
  - Organization-managed provisioning

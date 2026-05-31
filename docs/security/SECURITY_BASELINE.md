# Security Baseline

Anemone OS version 1 targets a stable Debian Trixie based public-sector office workstation.

## Baseline Principles

- Keep custom repositories out of the default build.
- Keep build process reproducible.
- Do not commit secrets.
- Do not commit generated ISO files.
- Review all custom hooks before release.
- Do not use Debian Sid/Unstable in the default production build.
- Do not depend on Microsoft, Amazon, Google, Meta, or other third-party package repositories in the default build.
- Do not disable TLS peer verification for package downloads.
- Do not use `trusted=yes` or `check-valid-until=no` in production repository definitions.

## Workstation Scope

The default v1 image is for ordinary office users in municipalities, government agencies, and regional public sector organizations.

The baseline includes desktop login, web browsing, email where required, office documents, PDF handling, printing, scanning, networking, audio, video, firmware, fonts, and routine security updates.

Developer and cloud tooling, including SDKs, compilers, cloud CLIs, and repository clients, must be provided only through a separately documented optional profile.

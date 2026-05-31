# ADR 0002: Public sector workstation baseline

## Status

Accepted.

## Context

Anemone OS v1 is intended for municipalities, government agencies, and regional public sector organizations. The default workstation must work out of the box for ordinary office users.

The previous proof of concept included developer and cloud tooling that does not match the v1 target audience.

## Decision

Anemone OS v1 is a stable Debian Trixie based office workstation, not a developer workstation.

The default image includes the GNOME desktop, browser, office suite, PDF reader, printing, scanning, networking, audio, video, fonts, firmware, locale support, and basic support utilities.

The default image excludes compiler toolchains, SDKs, cloud CLIs, developer Python tooling, and other software intended primarily for developers or cloud engineers.

## Consequence

Developer and cloud tooling may be added later as an optional profile, but it must not be part of the v1 production baseline.

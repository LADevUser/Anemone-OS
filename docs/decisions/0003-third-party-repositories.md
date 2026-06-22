# ADR 0003: Third-party repositories

## Status

Accepted.

## Context

Third-party package repositories add supply-chain, trust, availability, support, and compatibility risk. A public-sector workstation baseline should remain predictable and auditable.

## Decision

The Anemone OS v1 default build must use Debian Trixie repositories only.

The default build must not depend on Microsoft, Amazon, Google, Meta, or other third-party package repositories. Repository files may be kept disabled for reference, but they must not be active in the default production build.

The default build must not disable TLS peer verification, use broad `trusted=yes` repository trust, or disable repository freshness checks with `check-valid-until=no`.

## Consequence

Software requiring third-party repositories must be documented as an optional profile or site-specific integration. It must not be required to build or boot the default v1 image.

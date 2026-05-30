# ADR 0002: External package sources

## Status

Accepted with restrictions.

## Context

Anemone OS currently includes Microsoft package sources for tools such as Azure CLI and .NET.

## Decision

External package sources are allowed only when explicitly documented and required for the target environment.

## Restrictions

- Debian Sid/Unstable must not be used in the default production build.
- Third-party repositories must be reviewed before release.
- Use of `trusted=yes` and `check-valid-until=no` must be removed or justified before production release.

## Consequence

The v1 release process must include package source review.

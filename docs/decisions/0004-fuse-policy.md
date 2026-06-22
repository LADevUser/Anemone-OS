# ADR 0004: FUSE policy

## Status

Accepted.

## Context

The old proof of concept contained a Sid-based workaround to install legacy FUSE packages. That is not appropriate for a stable Debian Trixie production baseline.

## Decision

Anemone OS v1 uses `fuse3` by default.

The default build must not depend on Debian Sid/Unstable. It must not install `libfuse2` or `libfuse2t64` unless a named supported application explicitly requires legacy FUSE and the exception is documented.

## Consequence

Legacy FUSE compatibility is treated as an application-specific exception, not a platform default.

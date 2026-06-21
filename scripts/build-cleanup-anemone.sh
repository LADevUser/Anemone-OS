#!/usr/bin/env bash

set -e

sudo lb clean --purge || true

sudo rm -rf \
  live-build/.build \
  live-build/cache \
  live-build/chroot \
  live-build/binary

sudo chown -R $USER:$USER .

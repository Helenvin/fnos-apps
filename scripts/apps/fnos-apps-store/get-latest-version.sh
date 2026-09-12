#!/bin/bash
set -euo pipefail

# Helenvin patch: the store app is published manually as fnos-apps-store/v1.9.5-hv1
# (patched binary pointing the catalog at this fork). Do not track upstream here,
# otherwise the daily cron would rebuild the official store and flip the catalog
# entry back to conversun. Bump VERSION manually when republishing.
VERSION="1.9.5-hv1"
echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi

#!/bin/bash
set -euo pipefail

# Helenvin patch: the store app is published manually as fnos-apps-store/v1.9.8.1-hv1
# (patched binary pointing the catalog at this fork, plus the
# manifest.go change that stops dropping installed apps whose fpk distributor is
# not "conversun"). Do not track upstream here,
# otherwise the daily cron would rebuild the official store and flip the catalog
# entry back to conversun. Bump VERSION manually when republishing.
#
# 1.9.8.1-hv1 (2026-09-29): identical store-server binary as 1.9.8-hv1 (no Go
# change) — repackaged so the desktop entry opens INSIDE the fnOS window instead
# of a new browser tab (ui/config type: url -> iframe).
# NOTE: the version must gain a NEW base segment (1.9.8 -> 1.9.8.1) instead of a
# plain -r1 revision. core.CompareFpkVersions() reports "not newer" for any two
# strings sharing the same base, so POST /api/store-update would refuse an -r1
# package with "已是最新版本".
VERSION="1.9.8.1-hv1"
echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi

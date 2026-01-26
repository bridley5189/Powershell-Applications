# Vendor Binaries

This repository excludes vendor binaries from source control to keep the repo small and avoid licensing issues.

## Excluded Files
- `cmtrace.exe` — Microsoft Configuration Manager log viewer
- `ConfigMgrTools.msi` — Microsoft Configuration Manager toolkit

## How to Obtain
- Download official binaries from Microsoft or your licensed distribution source.
- Place them locally as needed; do not commit into the repo. Prefer attaching binaries to a GitHub Release instead of storing in `main`.

## Recommended Practice
- Publish binaries as **GitHub Release assets**.
- Reference download locations in documentation without redistributing proprietary files.

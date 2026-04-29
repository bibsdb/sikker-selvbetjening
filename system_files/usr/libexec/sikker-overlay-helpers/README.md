# Overlay Helpers

This directory defines a drop-in helper framework for applying normalized overlay data.

## Contract

Every helper receives exactly three positional arguments:

1. Path to normalized overlay payload JSON
2. Path to mounted assets root
3. Path to output root

Helpers should be idempotent and should exit `0` when the section they care about is not configured.

## Layout

- `enabled/`: executable helper scripts run in lexicographic order
- `lib/`: shared utility functions used by helpers

## Naming Convention

Prefix helpers with a numeric order key:

- `10-desktop-background.sh`
- `20-printers.sh`
- `30-browser-defaults.sh`

This gives stable ordering while keeping helpers independent.

## Orchestrator

Use `scripts/sikker-apply-overlay.sh` in the base image as the entrypoint. It runs all executable helpers in `SIKKER_HELPERS_DIR` or the default `/usr/libexec/sikker-overlay-helpers/enabled`.

#!/usr/bin/env bash
set -euo pipefail

# Listen to real-time udev events for USB subsystem
# --udev: use udev layer (not raw kernel events)
# --property: include device metadata (vendor, model, etc.)
# --subsystem-match=usb: filter only USB-related events
udevadm monitor --udev --property --subsystem-match=usb |
while read -r line; do

    # ACTION marks the start of a new udev event (add/remove/change/etc.)
    # When a new event starts, we reset per-event variables
    if [[ "$line" == ACTION=* ]]; then
        ACTION="${line#ACTION=}"
        DEVTYPE=""
        VENDOR=""
        MODEL=""
    fi

    # DEVTYPE helps filter real devices vs interfaces/hubs/etc.
    if [[ "$line" == DEVTYPE=* ]]; then
        DEVTYPE="${line#DEVTYPE=}"
    fi

    # Preferred human-readable vendor name (from udev database)
    if [[ "$line" == ID_VENDOR_FROM_DATABASE=* ]]; then
        VENDOR="${line#ID_VENDOR_FROM_DATABASE=}"
    fi

    # Preferred human-readable model name (from udev database)
    if [[ "$line" == ID_MODEL_FROM_DATABASE=* ]]; then
        MODEL="${line#ID_MODEL_FROM_DATABASE=}"
    fi

    # Fallbacks if database names are not available
    # These are raw USB identifiers (less readable)
    if [[ "$line" == ID_VENDOR=* && -z "${VENDOR:-}" ]]; then
        VENDOR="${line#ID_VENDOR=}"
    fi

    if [[ "$line" == ID_MODEL=* && -z "${MODEL:-}" ]]; then
        MODEL="${line#ID_MODEL=}"
    fi

    # Only act on actual USB device-level events (not interfaces)
    if [[ "${ACTION:-}" == "add" && "${DEVTYPE:-}" == "usb_device" ]]; then

        # Build final display name with safe fallbacks
        NAME="${VENDOR:-Unknown Vendor} - ${MODEL:-Unknown Device}"

        # GNOME desktop notification for device insertion
        notify-send -u critical -a "USB Devices" -t 10000 \
            "USB Connected" "$NAME"

        # Reset state to avoid leaking data into next event
        ACTION=""
        DEVTYPE=""
    fi

    # Handle USB device removal events
    if [[ "${ACTION:-}" == "remove" && "${DEVTYPE:-}" == "usb_device" ]]; then

        NAME="${VENDOR:-Unknown Vendor} - ${MODEL:-Unknown Device}"

        notify-send -u critical -a "USB Devices" -t 10000 \
            "USB Removed" "$NAME"

        ACTION=""
        DEVTYPE=""
    fi

done
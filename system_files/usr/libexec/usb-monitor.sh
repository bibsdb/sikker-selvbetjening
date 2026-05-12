#!/usr/bin/env bash
set -euo pipefail

udevadm monitor --udev --property --subsystem-match=usb |
while read -r line; do

    if [[ "$line" == ACTION=* ]]; then
        ACTION="${line#ACTION=}"
        DEVTYPE=""
        VENDOR=""
        MODEL=""
    fi

    if [[ "$line" == DEVTYPE=* ]]; then
        DEVTYPE="${line#DEVTYPE=}"
    fi

    if [[ "$line" == ID_VENDOR_FROM_DATABASE=* ]]; then
        VENDOR="${line#ID_VENDOR_FROM_DATABASE=}"
    fi

    if [[ "$line" == ID_MODEL_FROM_DATABASE=* ]]; then
        MODEL="${line#ID_MODEL_FROM_DATABASE=}"
    fi

    # fallback if database names are missing
    if [[ "$line" == ID_VENDOR=* && -z "${VENDOR:-}" ]]; then
        VENDOR="${line#ID_VENDOR=}"
    fi

    if [[ "$line" == ID_MODEL=* && -z "${MODEL:-}" ]]; then
        MODEL="${line#ID_MODEL=}"
    fi

    if [[ "${ACTION:-}" == "add" && "${DEVTYPE:-}" == "usb_device" ]]; then

        NAME="${VENDOR:-Unknown Vendor} - ${MODEL:-Unknown Device}"

        notify-send -u critical "USB Connected" "$NAME"

        ACTION=""
        DEVTYPE=""
    fi

    if [[ "${ACTION:-}" == "remove" && "${DEVTYPE:-}" == "usb_device" ]]; then

        NAME="${VENDOR:-Unknown Vendor} - ${MODEL:-Unknown Device}"

        notify-send -u critical "USB Removed" "$NAME"

        ACTION=""
        DEVTYPE=""
    fi

done
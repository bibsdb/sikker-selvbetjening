#!/bin/bash

# Configuration
LOGOUT_TITLE="Log ud?"
LOGOUT_MESSAGE="Er du sikker på, at du vil logge ud?\n\nAlt du har gjort bliver slettet og computeeren genstarter, for din digital sikkerhed."
OK_LABEL="Ja, log mig ud"
CANCEL_LABEL="Nej, Arbejd videre"

echo "[+] Kiosk Manual Logout Triggered."

zenity --question \
       --title="$LOGOUT_TITLE" \
       --text="$LOGOUT_MESSAGE" \
       --ok-label="$OK_LABEL" \
       --cancel-label="$CANCEL_LABEL" \
       --width=420 \
       --modal

RESPONSE=$?

if [ "$RESPONSE" -eq 0 ]; then
    echo "[!] User confirmed logout. Executing secure kexec fast reboot..."
    # UPDATED: Replaced standard reboot with passwordless sudo kexec
    sudo /usr/bin/systemctl kexec
else
    echo "[~] Logout canceled by user. Returning to session."
    exit 0
fi
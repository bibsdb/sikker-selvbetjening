#!/bin/bash

# ==========================================
# CONFIGURATION: Add or remove URLs here
# Leave this empty () if you do not want Firefox to open.
# ==========================================
URLS=(
#   "example-url.com"
#   "https://www.youtube.com"
    "https://www.google.com"
    "https://en.wikipedia.org"
)


# 1. Check if the array is empty FIRST
# If empty, exit gracefully right away.
if [ ${#URLS[@]} -eq 0 ]; then
    echo "[~] No URLs defined. Admin disabled browser autostart. Exiting..."
    exit 0
fi


# 2. Network Safeguard: Only run if we actually have tabs to open
echo "[+] Found ${#URLS[@]} custom tabs. Waiting for active network connection..."
while ! ping -c 1 -W 1 1.1.1.1 &>/dev/null; do
    sleep 1
done


# 3. Launch Firefox
echo "[+] Network up. Launching Firefox..."
firefox "${URLS[@]}"
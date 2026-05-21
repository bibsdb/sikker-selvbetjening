#!/bin/bash
echo "[*] Nuclear Shutdown Handler Triggered."

# 1. Use pgrep to find ALL PIDs on the system.
# 2. Use 'grep -vE' to filter out the patterns you want to PROTECT.
# 3. Pipe the remaining PIDs to 'xargs kill -9' to force termination.

pgrep -v -f "reboot-handler.sh|systemd|dbus-daemon|sshd|bash" | xargs -r kill -9 2>/dev/null

# 2. Trigger the reboot
systemctl reboot
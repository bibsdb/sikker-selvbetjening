#!/bin/bash

set -ouex pipefail

# Write the oneshot service unit that fetches and applies bootc image updates.
# The service only reboots when an update is actually available: --check exits
# non-zero if no update is found, which short-circuits the && and skips --apply.
# --soft-reboot=auto uses a userspace-only restart when no kernel changes are
# staged, falling back to a full hardware reboot when they are.
cat > /usr/lib/systemd/system/bootc-update-check.service << 'EOF'
[Unit]
Description=Fetch and apply bootc image updates when available
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
# --check gates --apply so we only reboot when an update is detected.
ExecStart=/usr/bin/bash -c '/usr/bin/bootc upgrade --check && /usr/bin/bootc upgrade --apply --soft-reboot=auto'
EOF

# Write the timer unit that triggers the service once nightly at 02:00.
# OnCalendar schedules the timer for every day at 02:00 local time.
# Persistent=true ensures a missed run (e.g. the machine was off) is caught
# up the next time the timer activates.
cat > /usr/lib/systemd/system/bootc-update-check.timer << 'EOF'
[Unit]
Description=Run bootc update check nightly at 02:00

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true
Unit=bootc-update-check.service

[Install]
WantedBy=timers.target
EOF

# Enable system services in the image.
# podman.socket activates the Podman API on demand via socket activation.
# bootc-update-check.timer starts the automatic update cycle on every boot.
systemctl enable podman.socket
systemctl enable bootc-update-check.timer

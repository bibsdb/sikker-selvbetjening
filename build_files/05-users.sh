#!/bin/bash

set -ouex pipefail

# Create user 1000 to prevent first-boot user creation dialog
# This user will be the default interactive user
useradd -u 1000 -m -s /bin/bash -c "Super User" superuser

# Set password
echo "superuser:superuser" | chpasswd

# Allow sudo with password required
echo "superuser ALL=(ALL) ALL" >> /etc/sudoers.d/superuser
chmod 0440 /etc/sudoers.d/superuser

# Create Bruger (user) with ephemeral home (wiped on every boot via tmpfs)
useradd -u 1001 -m -s /bin/bash -c "Bruger" Bruger

# Set password for Bruger user
echo "Bruger:bruger" | chpasswd

# enable mounting Bruger in RAM for ephemeral home
systemctl enable home-Bruger.mount
systemctl enable bruger-home-init.service


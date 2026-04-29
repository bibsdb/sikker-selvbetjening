#!/bin/bash

set -ouex pipefail

# Install dconf profile and defaults.
install -d /etc/dconf/profile /etc/dconf/db/local.d
install -Dm0644 /ctx/system_files/etc/dconf/profile/user /etc/dconf/profile/user
cp -r /ctx/system_files/etc/dconf/db/local.d/* /etc/dconf/db/local.d/

dconf update

#!/bin/bash

set -ouex pipefail

# Install GDM auto-login file explicitly to ensure it is included in the final image.
install -Dm0644 /ctx/system_files/etc/gdm/custom.conf /etc/gdm/custom.conf

# Verify the installed file matches the source.
if ! cmp -s /etc/gdm/custom.conf /ctx/system_files/etc/gdm/custom.conf; then
    echo "/etc/gdm/custom.conf does not match source file" >&2
    exit 1
fi

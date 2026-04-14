#!/bin/bash

set -ouex pipefail

# Copy all dconf defaults
cp -r /ctx/system_files/etc/dconf/db/local.d/* /etc/dconf/db/local.d/

dconf update

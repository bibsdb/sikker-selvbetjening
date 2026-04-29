#!/bin/bash

set -ouex pipefail

# Install image-level defaults in /usr/etc so bootc/ostree can merge them into
# the target system without mutating runtime-managed files during the build.
install -d /usr/etc
install -Dm0644 /ctx/system_files/etc/hostname /usr/etc/hostname
install -Dm0644 /ctx/system_files/etc/locale.conf /usr/etc/locale.conf
install -Dm0644 /ctx/system_files/etc/vconsole.conf /usr/etc/vconsole.conf
install -Dm0644 /ctx/system_files/etc/X11/xorg.conf.d/00-keyboard.conf /usr/etc/X11/xorg.conf.d/00-keyboard.conf
ln -snf /usr/share/zoneinfo/Europe/Copenhagen /usr/etc/localtime

# Suppress GNOME Initial Setup even on direct bootc-based installs.
install -d /usr/etc/systemd/system /usr/etc/systemd/user
ln -snf /dev/null /usr/etc/systemd/system/gnome-initial-setup.service
ln -snf /dev/null /usr/etc/systemd/user/gnome-initial-setup-first-login.service

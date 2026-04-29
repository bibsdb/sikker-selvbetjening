#!/bin/bash

set -ouex pipefail

# Install image-level system defaults so they apply even without Anaconda.
install -Dm0644 /ctx/system_files/etc/hostname /etc/hostname
install -Dm0644 /ctx/system_files/etc/locale.conf /etc/locale.conf
install -Dm0644 /ctx/system_files/etc/vconsole.conf /etc/vconsole.conf
install -Dm0644 /ctx/system_files/etc/X11/xorg.conf.d/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf
ln -snf /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime

# Suppress GNOME Initial Setup even on direct bootc-based installs.
install -d /etc/systemd/system /etc/systemd/user
ln -snf /dev/null /etc/systemd/system/gnome-initial-setup.service
ln -snf /dev/null /etc/systemd/user/gnome-initial-setup-first-login.service

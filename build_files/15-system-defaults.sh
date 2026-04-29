#!/bin/bash

set -ouex pipefail

# Install static image defaults directly into /etc.
install -Dm0644 /ctx/system_files/etc/locale.conf /etc/locale.conf
install -Dm0644 /ctx/system_files/etc/vconsole.conf /etc/vconsole.conf
install -Dm0644 /ctx/system_files/etc/X11/xorg.conf.d/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf

# Install first-boot defaults payload for settings that are runtime-managed.
install -Dm0755 \
	/ctx/system_files/usr/libexec/sikker-apply-firstboot-defaults \
	/usr/libexec/sikker-apply-firstboot-defaults
install -Dm0644 /ctx/system_files/etc/hostname /usr/lib/sikker-selvbetjening/defaults/hostname
install -Dm0644 /ctx/system_files/etc/timezone /usr/lib/sikker-selvbetjening/defaults/timezone

cat > /usr/lib/systemd/system/sikker-apply-firstboot-defaults.service << 'EOF'
[Unit]
Description=Apply image defaults on first boot
ConditionFirstBoot=yes
After=local-fs.target
Before=display-manager.service gdm.service systemd-user-sessions.service

[Service]
Type=oneshot
ExecStart=/usr/libexec/sikker-apply-firstboot-defaults

[Install]
WantedBy=multi-user.target
EOF

systemctl enable sikker-apply-firstboot-defaults.service

# Suppress GNOME Initial Setup even on direct bootc-based installs.
install -d /etc/systemd/system /etc/systemd/user
ln -snf /dev/null /etc/systemd/system/gnome-initial-setup.service
ln -snf /dev/null /etc/systemd/user/gnome-initial-setup-first-login.service

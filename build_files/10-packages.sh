#!/bin/bash

set -ouex pipefail

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images.
dnf5 install -y \
	gnome-shell-extension-dash-to-panel \
	gnome-shell-extension-apps-menu \
	glibc-langpack-da \
	glibc-locale-source \
	libreoffice \
    libreoffice-langpack-da 
# Use a COPR Example:
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they do not end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#list of what each package does respectively:

# gnome-shell-extension-dash-to-panel: windows-like taskbar for gnome
# gnome-shell-extension-apps-menu: adds an applications menu to the top bar
# glibc-langpack-da: Danish language support for glibc
# glibc-locale-source: source files for glibc locales, needed to generate da_DK.UTF-8 locale
# libreoffice: office suite
# libreoffice-langpack-da: Danish language support for LibreOffice

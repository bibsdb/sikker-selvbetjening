#!/bin/bash

set -ouex pipefail

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images.
dnf5 install -y \
	tmux \
	gnome-shell-extension-dash-to-panel \
	glibc-langpack-da \
	libreoffice \
	libreoffice-langpack-da \
	hunspell-da 

# Use a COPR Example:
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they do not end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#glibc-langpack-da and libreoffice-langpack-da are used to get danish language support in the image.
#hunspell-da is used by LibreOffice for spell checking in danish.
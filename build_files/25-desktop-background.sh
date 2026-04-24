#!/bin/bash

set -ouex pipefail

# Install compile helper from system_files into the final image.
install -Dm0755 \
	/ctx/system_files/usr/libexec/sikker-compile-desktop-background \
	/usr/libexec/sikker-compile-desktop-background

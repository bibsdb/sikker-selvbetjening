#!/bin/bash

set -ouex pipefail

# Install overlay entrypoint used by downstream config/image builds.
install -Dm0755 \
	/ctx/system_files/usr/libexec/sikker-apply-overlay \
	/usr/libexec/sikker-apply-overlay

# Install overlay helpers tree consumed by sikker-apply-overlay.
install -d /usr/libexec/sikker-overlay-helpers
cp -a /ctx/system_files/usr/libexec/sikker-overlay-helpers/. /usr/libexec/sikker-overlay-helpers/

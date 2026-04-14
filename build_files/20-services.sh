#!/bin/bash

set -ouex pipefail

# Enable system services in the image.
systemctl enable podman.socket

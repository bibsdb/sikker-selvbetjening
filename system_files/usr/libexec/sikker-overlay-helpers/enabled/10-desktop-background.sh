#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/overlay-common.sh
source "${SCRIPT_DIR}/../lib/overlay-common.sh"

# Positional arguments passed in by sikker-apply-overlay
OVERLAY_PAYLOAD_FILE="${1:?overlay payload file required}"  # group_vars JSON file for this target
ASSETS_ROOT="${2:?assets root required}"                    # directory containing asset files
OUTPUT_ROOT="${3:?output root required}"                    # staging root written into the live system

overlay_require_file "${OVERLAY_PAYLOAD_FILE}"
overlay_require_dir "${ASSETS_ROOT}"

# Declare every overlay payload field this script needs.
# overlay_load extracts them all in a single Python call and returns bash
# declare statements; eval brings the variables into the current shell.
# Type ":asset" validates the assets/… prefix and strips it to a relative path.
overlay_fields \
  BACKGROUND_IMAGE_FILE=desktop.background_image_file:asset

eval "$(overlay_load "${OVERLAY_PAYLOAD_FILE}")"

# If the field is absent or empty, this script has nothing to do
[[ -z "${BACKGROUND_IMAGE_FILE}" ]] && exit 0

# Copy the background image into the output tree under a fixed well-known name
# so the dconf keyfile below can reference a stable path regardless of the
# original filename chosen by the overlay author
source_image="${ASSETS_ROOT}/${BACKGROUND_IMAGE_FILE}"
overlay_require_file "${source_image}"

mkdir -p "${OUTPUT_ROOT}/usr/share/backgrounds/sikker-selvbetjening"
cp -f "${source_image}" "${OUTPUT_ROOT}/usr/share/backgrounds/sikker-selvbetjening/default-background"

# Write a dconf keyfile that points GNOME at the copied background image.
# The file is picked up by dconf update on the next login or apply cycle.
mkdir -p "${OUTPUT_ROOT}/etc/dconf/db/local.d"
cat > "${OUTPUT_ROOT}/etc/dconf/db/local.d/03-desktop-background" <<'EOF'
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/sikker-selvbetjening/default-background'
picture-uri-dark='file:///usr/share/backgrounds/sikker-selvbetjening/default-background'
picture-options='zoom'
primary-color='#000000'
secondary-color='#000000'
EOF


#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/overlay-common.sh
source "${SCRIPT_DIR}/../lib/overlay-common.sh"

OVERLAY_PAYLOAD_FILE="${1:?overlay payload file required}"
ASSETS_ROOT="${2:?assets root required}"
OUTPUT_ROOT="${3:?output root required}"

overlay_require_file "${OVERLAY_PAYLOAD_FILE}"
overlay_require_dir "${ASSETS_ROOT}"

background_value="$(overlay_json_get_string "${OVERLAY_PAYLOAD_FILE}" "desktop.background_image_file" | tr -d '\r')"
if [[ -z "${background_value}" ]]; then
  exit 0
fi

background_rel_path="$(overlay_asset_relpath "${background_value}" | tr -d '\r')"
if [[ -z "${background_rel_path}" ]]; then
  exit 0
fi

source_image="${ASSETS_ROOT}/${background_rel_path}"
overlay_require_file "${source_image}"

mkdir -p "${OUTPUT_ROOT}/usr/share/backgrounds/sikker-selvbetjening"
cp -f "${source_image}" "${OUTPUT_ROOT}/usr/share/backgrounds/sikker-selvbetjening/default-background"

mkdir -p "${OUTPUT_ROOT}/etc/dconf/db/local.d"
cat > "${OUTPUT_ROOT}/etc/dconf/db/local.d/03-desktop-background" <<'EOF'
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/sikker-selvbetjening/default-background'
picture-uri-dark='file:///usr/share/backgrounds/sikker-selvbetjening/default-background'
picture-options='zoom'
primary-color='#000000'
secondary-color='#000000'
EOF

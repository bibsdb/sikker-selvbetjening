#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/overlay-common.sh
source "${SCRIPT_DIR}/../lib/overlay-common.sh"

OVERLAY_PAYLOAD_FILE="${1:?overlay payload file required}"
ASSETS_ROOT="${2:?assets root required}"
OUTPUT_ROOT="${3:?output root required}"

echo "[10-background] start"
echo "[10-background] OVERLAY_PAYLOAD_FILE=${OVERLAY_PAYLOAD_FILE}"
echo "[10-background] ASSETS_ROOT=${ASSETS_ROOT}"
echo "[10-background] OUTPUT_ROOT=${OUTPUT_ROOT}"

overlay_require_file "${OVERLAY_PAYLOAD_FILE}"
overlay_require_dir "${ASSETS_ROOT}"

background_value="$(overlay_json_get_string "${OVERLAY_PAYLOAD_FILE}" "desktop.background_image_file" | tr -d '\r')"
echo "[10-background] background_value=${background_value:-<empty>}"
if [[ -z "${background_value}" ]]; then
  echo "[10-background] no desktop.background_image_file, exiting"
  exit 0
fi

background_rel_path="$(overlay_asset_relpath "${background_value}" | tr -d '\r')"
echo "[10-background] background_rel_path=${background_rel_path:-<empty>}"
if [[ -z "${background_rel_path}" ]]; then
  echo "[10-background] asset path did not resolve, exiting"
  exit 0
fi

source_image="${ASSETS_ROOT}/${background_rel_path}"
echo "[10-background] source_image=${source_image}"
overlay_require_file "${source_image}"

mkdir -p "${OUTPUT_ROOT}/usr/share/backgrounds/sikker-selvbetjening"
cp -f "${source_image}" "${OUTPUT_ROOT}/usr/share/backgrounds/sikker-selvbetjening/default-background"
echo "[10-background] copied background"

mkdir -p "${OUTPUT_ROOT}/etc/dconf/db/local.d"
echo "[10-background] writing dconf file to ${OUTPUT_ROOT}/etc/dconf/db/local.d/03-desktop-background"
cat > "${OUTPUT_ROOT}/etc/dconf/db/local.d/03-desktop-background" <<'EOF'
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/sikker-selvbetjening/default-background'
picture-uri-dark='file:///usr/share/backgrounds/sikker-selvbetjening/default-background'
picture-options='zoom'
primary-color='#000000'
secondary-color='#000000'
EOF

if [[ -f "${OUTPUT_ROOT}/etc/dconf/db/local.d/03-desktop-background" ]]; then
  echo "[10-background] dconf file created"
  cat "${OUTPUT_ROOT}/etc/dconf/db/local.d/03-desktop-background"
else
  echo "[10-background] dconf file missing after write"
  exit 1
fi

echo "[10-background] done"
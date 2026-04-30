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
# wifi.ssid is required by the schema; psk and hidden are optional.
overlay_fields \
  WIFI_SSID=wifi.ssid:string \
  WIFI_PSK=wifi.psk:string \
  WIFI_HIDDEN=wifi.hidden:boolean

eval "$(overlay_load "${OVERLAY_PAYLOAD_FILE}")"

# If no SSID is configured this script has nothing to do
[[ -z "${WIFI_SSID}" ]] && exit 0

# NetworkManager keyfiles with credentials must be owned by root and not
# world-readable; NM refuses to load them otherwise
nm_dir="${OUTPUT_ROOT}/etc/NetworkManager/system-connections"
mkdir -p "${nm_dir}"
nm_file="${nm_dir}/${WIFI_SSID}.nmconnection"

# Build the keyfile in sections; optional sections are only emitted when the
# corresponding field is present in the overlay payload
{
  cat <<EOF
[connection]
id=${WIFI_SSID}
type=wifi
autoconnect=true

[wifi]
ssid=${WIFI_SSID}
mode=infrastructure
EOF

  # Emit hidden= only when explicitly set to true; the default (false) is
  # omitted so NM uses its own default
  [[ "${WIFI_HIDDEN}" == "true" ]] && echo "hidden=true"

  # WPA-PSK security section – only written when a pre-shared key is supplied
  if [[ -n "${WIFI_PSK}" ]]; then
    cat <<EOF

[wifi-security]
key-mgmt=wpa-psk
psk=${WIFI_PSK}
EOF
  fi

  cat <<'EOF'

[ipv4]
method=auto

[ipv6]
method=auto
EOF
} > "${nm_file}"

# NetworkManager rejects connection files that are world-readable when they
# contain credentials; 0600 is required in all cases for consistency
chmod 0600 "${nm_file}"

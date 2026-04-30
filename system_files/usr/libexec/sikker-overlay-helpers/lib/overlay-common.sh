#!/usr/bin/env bash
set -euo pipefail

overlay_die() {
  echo "$*" >&2
  exit 1
}

overlay_require_file() {
  local path="$1"
  [[ -f "${path}" ]] || overlay_die "Missing file: ${path}"
}

overlay_require_dir() {
  local path="$1"
  [[ -d "${path}" ]] || overlay_die "Missing directory: ${path}"
}

# Registry populated by overlay_fields(); consumed by overlay_load().
_OVERLAY_FIELDS=()

# overlay_fields VAR=section.key[:type] ...
#
# Declares the overlay payload fields a helper script needs.
# Each spec is:  BASH_VARNAME=dotted.json.key          (type defaults to "string")
#            or  BASH_VARNAME=dotted.json.key:string
#            or  BASH_VARNAME=dotted.json.key:asset     (assets/… path → relative path)
#            or  BASH_VARNAME=dotted.json.key:array     (JSON array → bash indexed array)
#
# Call this once at the top of each helper script, then call overlay_load.
overlay_fields() {
  _OVERLAY_FIELDS+=("$@")
}

# overlay_load OVERLAY_PAYLOAD_FILE
#
# Extracts all fields registered via overlay_fields from the JSON payload in a
# single Python invocation and prints bash declare statements.  Eval the output:
#
#   eval "$(overlay_load "${OVERLAY_PAYLOAD_FILE}")"
overlay_load() {
  local overlay_path="$1"
  local lib_dir
  lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  python3 "${lib_dir}/overlay_load.py" "${overlay_path}" "${_OVERLAY_FIELDS[@]}"
}

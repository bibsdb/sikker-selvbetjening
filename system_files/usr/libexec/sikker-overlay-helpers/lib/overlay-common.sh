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

overlay_json_get_string() {
  local overlay_path="$1"
  local dotted_key="$2"

  python3 - "${overlay_path}" "${dotted_key}" <<'PY'
import json
import sys

overlay_path = sys.argv[1]
dotted_key = sys.argv[2]

with open(overlay_path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

value = data
for part in dotted_key.split('.'):
    if not isinstance(value, dict) or part not in value:
        print("")
        raise SystemExit(0)
    value = value[part]

if isinstance(value, str):
    print(value)
else:
    print("")
PY
}

overlay_asset_relpath() {
  local asset_value="$1"

  python3 - "${asset_value}" <<'PY'
import posixpath
import sys

asset_value = sys.argv[1]

if not asset_value.startswith("assets/"):
    print("")
    raise SystemExit(0)

rel_path = posixpath.normpath(asset_value[7:])
if rel_path in (".", "") or rel_path.startswith("../") or "/../" in rel_path:
    print(f"Invalid asset path: {asset_value}", file=sys.stderr)
    raise SystemExit(1)

print(rel_path)
PY
}

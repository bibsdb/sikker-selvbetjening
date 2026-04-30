#!/usr/bin/env python3
"""
overlay_load.py – extract overlay payload fields for bash helper scripts.

Called by overlay_load() in overlay-common.sh.  Prints bash declare statements
for each requested field so the caller can eval them into its environment.

Usage:
    python3 overlay_load.py PAYLOAD_FILE [VAR=section.key[:type] ...]

Types:
    string  (default)  – scalar string; empty string when absent
    asset              – validates assets/… prefix, returns the relative path
    array              – JSON array → bash indexed array; empty array when absent
    boolean            – JSON boolean → "true" or "false"; empty string when absent
"""
import json
import posixpath
import shlex
import sys


def get_nested(data: dict, dotted_key: str):
    """Return the value at dotted_key in data, or None if any step is missing."""
    value = data
    for part in dotted_key.split("."):
        if not isinstance(value, dict) or part not in value:
            return None
        value = value[part]
    return value


def asset_relpath(raw) -> str:
    """Validate and strip the assets/ prefix from an asset field value."""
    if not isinstance(raw, str) or not raw.startswith("assets/"):
        return ""
    rel = posixpath.normpath(raw[7:])
    if rel in (".", "") or rel.startswith("../") or "/../" in rel:
        print(f"Invalid asset path: {raw}", file=sys.stderr)
        raise SystemExit(1)
    return rel


def render_field(var_name: str, key: str, ftype: str, data: dict) -> str:
    """Return a bash declare statement for a single field spec."""
    raw = get_nested(data, key)

    if ftype == "string":
        return f"declare -- {var_name}={shlex.quote(raw if isinstance(raw, str) else '')}"
    elif ftype == "asset":
        return f"declare -- {var_name}={shlex.quote(asset_relpath(raw))}"
    elif ftype == "array":
        if isinstance(raw, list):
            items = " ".join(f"[{i}]={shlex.quote(str(v))}" for i, v in enumerate(raw))
            return f"declare -a {var_name}=({items})"
        return f"declare -a {var_name}=()"
    elif ftype == "boolean":
        if isinstance(raw, bool):
            return f"declare -- {var_name}={shlex.quote('true' if raw else 'false')}"
        return f"declare -- {var_name}=''"
    else:
        print(f"Unknown field type '{ftype}' for {var_name}", file=sys.stderr)
        raise SystemExit(1)


def parse_spec(spec: str) -> tuple[str, str, str]:
    """Parse 'VAR=section.key[:type]' into (var_name, key, ftype)."""
    eq = spec.index("=")
    var_name = spec[:eq]
    rest = spec[eq + 1:]
    if ":" in rest:
        colon = rest.rindex(":")
        key = rest[:colon]
        ftype = rest[colon + 1:]
    else:
        key = rest
        ftype = "string"
    return var_name, key, ftype


def main(argv: list[str]) -> None:
    if len(argv) < 2:
        print(f"Usage: {argv[0]} PAYLOAD_FILE [VAR=key[:type] ...]", file=sys.stderr)
        raise SystemExit(1)

    overlay_path = argv[1]
    field_specs = argv[2:]

    with open(overlay_path, "r", encoding="utf-8") as fh:
        data = json.load(fh)

    for spec in field_specs:
        var_name, key, ftype = parse_spec(spec)
        print(render_field(var_name, key, ftype, data))


if __name__ == "__main__":
    main(sys.argv)

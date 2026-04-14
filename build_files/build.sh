#!/bin/bash

set -ouex pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run all numbered build steps in lexical order, e.g. 10-*.sh, 20-*.sh.
for script in "$script_dir"/[0-9][0-9]-*.sh; do
	[ -e "$script" ] || continue
	bash "$script"
done

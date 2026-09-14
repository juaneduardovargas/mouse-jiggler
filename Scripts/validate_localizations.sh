#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/mouse-jiggler-l10n.XXXXXX")"

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

extract_keys() {
    plutil -p "$1" \
        | sed -n 's/^  "\(.*\)" =>.*/\1/p' \
        | sort \
        > "$2"
}

validate_pair() {
    local table_name="$1"
    local english_file="$ROOT_DIR/Resources/en.lproj/$table_name.strings"
    local spanish_file="$ROOT_DIR/Resources/es.lproj/$table_name.strings"

    plutil -lint "$english_file" >/dev/null
    plutil -lint "$spanish_file" >/dev/null

    extract_keys "$english_file" "$TEMP_DIR/$table_name.en.keys"
    extract_keys "$spanish_file" "$TEMP_DIR/$table_name.es.keys"

    if ! diff -u "$TEMP_DIR/$table_name.en.keys" "$TEMP_DIR/$table_name.es.keys"; then
        echo "$table_name localization keys do not match." >&2
        exit 1
    fi
}

validate_pair "Localizable"
validate_pair "InfoPlist"

echo "Localization files are valid and contain matching keys."

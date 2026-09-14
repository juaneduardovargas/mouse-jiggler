#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="MouseJiggler"
BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_STAGE_DIR="$BUILD_DIR/dmg-root"
DMG_PATH="$DIST_DIR/$APP_NAME.dmg"

if [[ ! -d "$APP_BUNDLE" ]]; then
    echo "No se encontro $APP_BUNDLE. Ejecuta primero el build de la app." >&2
    exit 1
fi

rm -rf "$DMG_STAGE_DIR"
mkdir -p "$DMG_STAGE_DIR"

cp -R "$APP_BUNDLE" "$DMG_STAGE_DIR/"
ln -s /Applications "$DMG_STAGE_DIR/Applications"

rm -f "$DMG_PATH"
hdiutil create \
    -volname "Mouse Jiggler" \
    -srcfolder "$DMG_STAGE_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH" >/dev/null

echo "DMG creada en: $DMG_PATH"

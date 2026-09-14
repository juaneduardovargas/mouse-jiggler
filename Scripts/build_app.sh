#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="MouseJiggler"
ARCH="$(uname -m)"
APP_SIGN_IDENTITY="${APP_SIGN_IDENTITY:--}"
BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DIST_APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ICONSET_DIR="$BUILD_DIR/AppIcon.iconset"
ZIP_PATH="$DIST_DIR/$APP_NAME.zip"
DMG_PATH="$DIST_DIR/$APP_NAME.dmg"
PKG_PATH="$DIST_DIR/$APP_NAME.pkg"

rm -rf "$APP_BUNDLE" "$DIST_APP_BUNDLE" "$ICONSET_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$DIST_DIR"

swift "$ROOT_DIR/Scripts/generate_icon.swift" "$ICONSET_DIR"
iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"
cp "$ROOT_DIR/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"

xcrun swiftc \
    -target "$ARCH-apple-macosx13.0" \
    -module-name "$APP_NAME" \
    -emit-executable \
    "$ROOT_DIR"/Sources/MouseJiggler/*.swift \
    -framework SwiftUI \
    -framework AppKit \
    -framework ApplicationServices \
    -framework ServiceManagement \
    -o "$MACOS_DIR/$APP_NAME"

codesign --force --deep --sign "$APP_SIGN_IDENTITY" "$APP_BUNDLE" >/dev/null
cp -R "$APP_BUNDLE" "$DIST_APP_BUNDLE"
rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_BUNDLE" "$ZIP_PATH"
zsh "$ROOT_DIR/Scripts/create_dmg.sh"
zsh "$ROOT_DIR/Scripts/create_pkg.sh"

echo "App creada en: $APP_BUNDLE"
echo "App copiada en: $DIST_APP_BUNDLE"
echo "ZIP creado en: $ZIP_PATH"
echo "DMG creada en: $DMG_PATH"
echo "PKG creada en: $PKG_PATH"

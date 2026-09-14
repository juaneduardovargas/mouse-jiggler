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

zsh "$ROOT_DIR/Scripts/validate_localizations.sh"
swift "$ROOT_DIR/Scripts/generate_icon.swift" "$ICONSET_DIR"
iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"
cp "$ROOT_DIR/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
cp -R "$ROOT_DIR"/Resources/*.lproj "$RESOURCES_DIR/"

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

if [[ "$APP_SIGN_IDENTITY" == "-" ]]; then
    codesign --force --deep --sign - "$APP_BUNDLE" >/dev/null
else
    codesign \
        --force \
        --deep \
        --options runtime \
        --timestamp \
        --sign "$APP_SIGN_IDENTITY" \
        "$APP_BUNDLE" >/dev/null
fi
cp -R "$APP_BUNDLE" "$DIST_APP_BUNDLE"
rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_BUNDLE" "$ZIP_PATH"
zsh "$ROOT_DIR/Scripts/create_dmg.sh"
zsh "$ROOT_DIR/Scripts/create_pkg.sh"

echo "App created at: $APP_BUNDLE"
echo "App copied to: $DIST_APP_BUNDLE"
echo "ZIP created at: $ZIP_PATH"
echo "DMG created at: $DMG_PATH"
echo "PKG created at: $PKG_PATH"

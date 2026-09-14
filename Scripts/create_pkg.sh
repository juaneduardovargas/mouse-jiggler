#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="MouseJiggler"
BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
PKG_STAGE_DIR="$BUILD_DIR/pkg-root"
PKG_PATH="$DIST_DIR/$APP_NAME.pkg"
INSTALLER_SIGN_IDENTITY="${INSTALLER_SIGN_IDENTITY:-}"

if [[ ! -d "$APP_BUNDLE" ]]; then
    echo "No se encontro $APP_BUNDLE. Ejecuta primero el build de la app." >&2
    exit 1
fi

rm -rf "$PKG_STAGE_DIR"
mkdir -p "$PKG_STAGE_DIR/Applications"
cp -R "$APP_BUNDLE" "$PKG_STAGE_DIR/Applications/"

rm -f "$PKG_PATH"
pkgbuild \
    --root "$PKG_STAGE_DIR" \
    --identifier "com.juan.mousejiggler.pkg" \
    --version "1.0" \
    --install-location "/" \
    "$PKG_PATH" >/dev/null

if [[ -n "$INSTALLER_SIGN_IDENTITY" ]]; then
    SIGNED_PKG_PATH="$DIST_DIR/$APP_NAME-signed.pkg"
    productsign --sign "$INSTALLER_SIGN_IDENTITY" "$PKG_PATH" "$SIGNED_PKG_PATH" >/dev/null
    mv -f "$SIGNED_PKG_PATH" "$PKG_PATH"
fi

echo "PKG creada en: $PKG_PATH"

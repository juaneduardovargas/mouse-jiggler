# Guía de publicación

[Read in English](../RELEASING.md)

Esta guía está dirigida a mantenedores que publiquen una versión firmada y notarizada de Mouse Jiggler. Nunca incluyas certificados, contraseñas, claves de App Store Connect ni perfiles del llavero en el repositorio.

## Requisitos previos

- Membresía activa en Apple Developer Program.
- Certificados `Developer ID Application` y `Developer ID Installer` instalados en Acceso a Llaveros.
- Un perfil de llavero para notarytool creado con `xcrun notarytool store-credentials`.
- Rama `main` limpia y CI aprobado.

## 1. Preparar la versión

1. Actualiza `CFBundleShortVersionString` y `CFBundleVersion` en `Resources/Info.plist`.
2. Mueve las entradas correspondientes de `Unreleased` a la nueva versión en `CHANGELOG.md`.
3. Confirma que la documentación en inglés y español describa el mismo comportamiento.

## 2. Validar el código fuente

```bash
zsh Scripts/validate_localizations.sh
git diff --check
```

## 3. Crear artefactos firmados

```bash
APP_SIGN_IDENTITY="Developer ID Application: Tu Nombre (TEAMID)" \
INSTALLER_SIGN_IDENTITY="Developer ID Installer: Tu Nombre (TEAMID)" \
zsh Scripts/build_app.sh
```

Verifica la app y el instalador:

```bash
codesign --verify --deep --strict --verbose=2 dist/MouseJiggler.app
pkgutil --check-signature dist/MouseJiggler.pkg
spctl --assess --type execute --verbose=2 dist/MouseJiggler.app
```

## 4. Notarizar y grapar

Envía los artefactos con el perfil de llavero configurado para notarytool:

```bash
xcrun notarytool submit dist/MouseJiggler.dmg \
  --keychain-profile "mouse-jiggler-notary" \
  --wait

xcrun notarytool submit dist/MouseJiggler.pkg \
  --keychain-profile "mouse-jiggler-notary" \
  --wait

xcrun stapler staple dist/MouseJiggler.dmg
xcrun stapler staple dist/MouseJiggler.pkg
xcrun stapler validate dist/MouseJiggler.dmg
xcrun stapler validate dist/MouseJiggler.pkg
```

Realiza una evaluación final de Gatekeeper en una cuenta limpia o en otro Mac antes de publicar.

## 5. Etiquetar y publicar

```bash
git tag -s vX.Y.Z -m "Mouse Jiggler vX.Y.Z"
git push origin main
git push origin vX.Y.Z
```

Crea un GitHub Release desde la etiqueta, copia la sección correspondiente del changelog y adjunta los archivos `.dmg` y `.pkg` notarizados. Publica también sus checksums:

```bash
shasum -a 256 dist/MouseJiggler.dmg dist/MouseJiggler.pkg
```

No publiques artefactos locales con firma ad-hoc como una versión oficial.

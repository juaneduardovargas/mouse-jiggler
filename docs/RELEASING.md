# Release guide

[Leer en español](es/RELEASING.md)

This guide is for maintainers publishing a signed and notarized Mouse Jiggler release. Never commit certificates, passwords, App Store Connect keys, or keychain profiles.

## Prerequisites

- An active Apple Developer Program membership.
- `Developer ID Application` and `Developer ID Installer` certificates installed in Keychain Access.
- A notarytool keychain profile created with `xcrun notarytool store-credentials`.
- A clean `main` branch with passing CI.

## 1. Prepare the version

1. Update `CFBundleShortVersionString` and `CFBundleVersion` in `Resources/Info.plist`.
2. Move the relevant entries from `Unreleased` to the new version in `CHANGELOG.md`.
3. Confirm that English and Spanish documentation describe the same release behavior.

## 2. Validate the source

```bash
zsh Scripts/validate_localizations.sh
git diff --check
```

## 3. Create signed artifacts

```bash
APP_SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
INSTALLER_SIGN_IDENTITY="Developer ID Installer: Your Name (TEAMID)" \
zsh Scripts/build_app.sh
```

Verify the app and installer:

```bash
codesign --verify --deep --strict --verbose=2 dist/MouseJiggler.app
pkgutil --check-signature dist/MouseJiggler.pkg
spctl --assess --type execute --verbose=2 dist/MouseJiggler.app
```

## 4. Notarize and staple

Submit the distributable artifacts using the keychain profile configured for notarytool:

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

Run a final Gatekeeper assessment on a clean test account or another Mac before publishing.

## 5. Tag and publish

```bash
git tag -s vX.Y.Z -m "Mouse Jiggler vX.Y.Z"
git push origin main
git push origin vX.Y.Z
```

Create a GitHub Release from the tag, copy the matching changelog section into the release notes, and attach the notarized `.dmg` and `.pkg`. Publish checksums alongside the artifacts:

```bash
shasum -a 256 dist/MouseJiggler.dmg dist/MouseJiggler.pkg
```

Do not upload ad-hoc-signed local artifacts as an official release.

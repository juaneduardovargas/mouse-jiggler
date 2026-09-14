<p align="center">
  <img src="docs/assets/app-icon.png" width="140" alt="Mouse Jiggler app icon">
</p>

<h1 align="center">Mouse Jiggler for macOS</h1>

<p align="center">
  A lightweight, native menu bar utility that helps keep your session active with tiny, configurable cursor movements.
</p>

<p align="center">
  <a href="README.es.md">Español</a> · <strong>English</strong>
</p>

<p align="center">
  <a href="https://github.com/juaneduardovargas/mouse-jiggler/actions/workflows/ci.yml"><img src="https://github.com/juaneduardovargas/mouse-jiggler/actions/workflows/ci.yml/badge.svg" alt="Build status"></a>
  <img src="https://img.shields.io/badge/macOS-13%2B-111111?logo=apple" alt="macOS 13 or later">
  <img src="https://img.shields.io/badge/Swift-native-F05138?logo=swift&logoColor=white" alt="Native Swift application">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-0A7EA4" alt="MIT License"></a>
</p>

## Preview

| Control panel | Menu bar controls |
| --- | --- |
| ![Mouse Jiggler control panel](docs/assets/control-panel.png) | ![Mouse Jiggler menu bar menu](docs/assets/menu-bar.png) |

## Why Mouse Jiggler?

Mouse Jiggler is a small, transparent macOS utility for situations where you want to help keep a workstation session active during a presentation, long-running task, remote session, or monitored process. It runs locally, uses native Apple frameworks, and does not collect or transmit data.

### Features

- Configurable movement interval from `0.5` to `3600` seconds.
- Visible `Active` / `Inactive` indicator in the macOS menu bar.
- Quick actions to start, stop, move once, and open the control panel.
- Optional automatic movement when the app opens.
- Optional launch at login through macOS Service Management.
- English and Spanish interface based on the macOS language preference.
- Native SwiftUI and AppKit implementation with no third-party dependencies.
- `.app`, `.zip`, `.dmg`, and `.pkg` build outputs.

## Requirements

- macOS 13 Ventura or later.
- Accessibility permission to generate cursor movement.
- Xcode Command Line Tools for builds from source.

The build script targets the architecture of the Mac running it (`arm64` or `x86_64`). Release maintainers can create separate artifacts or a universal binary when required.

## Installation

### From a GitHub Release

1. Download the latest artifact from [Releases](https://github.com/juaneduardovargas/mouse-jiggler/releases).
2. Open the `.dmg` and drag `MouseJiggler.app` into `Applications`.
3. Launch the app and approve Accessibility access when prompted.

Until official signed and notarized releases are available, macOS may show a Gatekeeper warning. For personal builds, right-click the app and choose **Open**, or build it locally from source.

### Build from source

```bash
git clone https://github.com/juaneduardovargas/mouse-jiggler.git
cd mouse-jiggler
zsh Scripts/build_app.sh
```

Generated artifacts:

- `build/MouseJiggler.app`
- `dist/MouseJiggler.app`
- `dist/MouseJiggler.zip`
- `dist/MouseJiggler.dmg`
- `dist/MouseJiggler.pkg`

Build and distribution artifacts are intentionally ignored by Git.

## Usage

1. Open Mouse Jiggler.
2. Click the `Active` or `Inactive` indicator in the menu bar.
3. Choose **Start movement**, or open the control panel to configure the interval.
4. Grant Accessibility permission in **System Settings → Privacy & Security → Accessibility**.
5. Choose **Stop movement** whenever you want to pause it.

The app moves the cursor by only a few pixels and immediately restores its original position.

## Permissions and privacy

Mouse Jiggler requires Accessibility permission because macOS restricts synthetic input events. The permission is used only to post local mouse movement events.

- No analytics.
- No network requests.
- No account or sign-in.
- No cursor history stored on disk.
- Preferences are stored locally with `UserDefaults`.

See [SECURITY.md](SECURITY.md) for responsible disclosure information.

## Localization

The app follows the preferred language configured in macOS. English is the development and fallback language; Spanish is included as a complete localization.

```text
Resources/
├── en.lproj/Localizable.strings
└── es.lproj/Localizable.strings
```

Validate localization syntax and key parity with:

```bash
zsh Scripts/validate_localizations.sh
```

## Signing and notarization

Local builds use ad-hoc signing by default. To use Developer ID identities:

```bash
APP_SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
INSTALLER_SIGN_IDENTITY="Developer ID Installer: Your Name (TEAMID)" \
zsh Scripts/build_app.sh
```

A Developer ID signature alone does not remove every Gatekeeper warning. Public distribution should also be notarized and stapled. The full process is documented in [docs/RELEASING.md](docs/RELEASING.md).

## Project structure

```text
Sources/MouseJiggler/   Application source code
Resources/              Bundle metadata and localizations
Scripts/                Build, packaging, and validation tools
docs/                   Architecture, release guides, and visual assets
.github/                 CI and contribution templates
```

For a component-level explanation, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Troubleshooting

### The cursor does not move

Open **System Settings → Privacy & Security → Accessibility**, enable Mouse Jiggler, then restart the app and choose **Refresh permissions**.

### The menu bar indicator is missing

Quit older copies of Mouse Jiggler, launch the copy installed in `Applications`, and check whether macOS has hidden menu bar extras because of limited space.

### macOS blocks the app or installer

Unsigned or ad-hoc-signed builds are intended for local development. Build from source, use **Open** from the Finder context menu, or use a signed and notarized release.

### Launch at login cannot be enabled

Move the app to `Applications`, launch that installed copy, and try again. macOS login-item registration expects the application to remain in a stable location.

## Contributing

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. Please use the bilingual issue forms for bugs and feature requests.

Community resources:

- [Support](SUPPORT.md)
- [Security policy](SECURITY.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Changelog](CHANGELOG.md)
- [Release guide](docs/RELEASING.md)

## License

Mouse Jiggler is available under the [MIT License](LICENSE).

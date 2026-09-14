# Contributing to Mouse Jiggler

Thank you for helping improve Mouse Jiggler. Contributions of code, documentation, translations, testing, and issue triage are welcome.

[Leer en español](docs/es/CONTRIBUTING.md)

## Before you start

- Read the [Code of Conduct](CODE_OF_CONDUCT.md).
- Search existing issues before opening a new one.
- Use the bilingual bug or feature form when possible.
- Keep changes focused. Large behavior changes should be discussed in an issue first.

## Development setup

You need macOS 13 or later and Xcode Command Line Tools.

```bash
git clone https://github.com/juaneduardovargas/mouse-jiggler.git
cd mouse-jiggler
zsh Scripts/validate_localizations.sh
zsh Scripts/build_app.sh
open build/MouseJiggler.app
```

The app requires Accessibility permission to test cursor movement. Compilation and localization validation do not require that permission.

## Project conventions

- Use Swift and native Apple frameworks already present in the project.
- Keep user-facing strings out of Swift source files. Add them to both localization files.
- Use semantic localization keys grouped by feature, such as `menu.start` or `permission.required`.
- Add DocC comments to types or behavior that are not self-explanatory.
- Prefer small, reviewable changes and avoid unrelated formatting.
- Do not commit `build/`, `dist/`, credentials, certificates, or provisioning material.

## Adding or changing translations

Update both files:

- `Resources/en.lproj/Localizable.strings`
- `Resources/es.lproj/Localizable.strings`

Then run:

```bash
zsh Scripts/validate_localizations.sh
```

English is the development and fallback language. Preserve format placeholders such as `%@` and `%d` in every translation.

## Verification

Before opening a pull request, run:

```bash
zsh Scripts/validate_localizations.sh
zsh Scripts/build_app.sh
codesign --verify --deep --strict build/MouseJiggler.app
git diff --check
```

For UI changes, test the app in both English and Spanish and include updated screenshots when presentation changes materially.

## Pull requests

A good pull request:

- Explains the problem and the chosen solution.
- Links the related issue when one exists.
- Describes manual testing performed.
- Updates documentation and translations when needed.
- Keeps generated artifacts out of the commit.

By contributing, you agree that your contribution will be licensed under the [MIT License](LICENSE).

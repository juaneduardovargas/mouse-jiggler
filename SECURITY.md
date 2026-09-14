# Security Policy

[Leer en español](docs/es/SECURITY.md)

Mouse Jiggler runs locally and does not intentionally make network requests. Security reports are still welcome, particularly when they involve Accessibility permissions, code signing, packaging, or login-item behavior.

## Supported versions

| Version | Supported |
| --- | --- |
| Latest `main` branch | Yes |
| Latest tagged release | Yes |
| Older releases | Best effort |

## Reporting a vulnerability

Please do not open a public issue for a suspected vulnerability.

1. Open the repository's **Security** tab.
2. Select **Report a vulnerability** to create a private security advisory.
3. Include the affected version, macOS version, impact, reproduction steps, and any suggested mitigation.

If private vulnerability reporting is not yet enabled, contact the maintainer using the contact method listed on [Juan Eduardo Vargas's GitHub profile](https://github.com/juaneduardovargas). Do not include sensitive details in a public issue.

The maintainer will make a best effort to acknowledge reports within seven days, provide progress updates, and coordinate disclosure after a fix is available.

## Security expectations

- Never commit Apple certificates, private keys, notarization credentials, or keychain exports.
- Treat unsigned and ad-hoc-signed artifacts as development builds.
- Verify release artifacts before publishing them.
- Keep Accessibility usage limited to the cursor movement behavior described by the project.

Good-faith security research that avoids privacy violations, data loss, and service disruption is welcome.

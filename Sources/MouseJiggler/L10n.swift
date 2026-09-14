import Foundation

/// Resolves localized user-facing strings from the app bundle.
enum L10n {
    /// Returns a localized value and falls back to the English source text.
    static func text(_ key: String, fallback: String) -> String {
        Bundle.main.localizedString(forKey: key, value: fallback, table: nil)
    }

    /// Resolves and formats a localized value using the user's current locale.
    static func format(_ key: String, fallback: String, _ arguments: CVarArg...) -> String {
        let template = text(key, fallback: fallback)
        return String(format: template, locale: Locale.current, arguments: arguments)
    }
}

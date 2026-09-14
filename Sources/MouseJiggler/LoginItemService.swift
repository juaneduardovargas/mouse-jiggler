import Foundation
import ServiceManagement

/// Wraps Service Management APIs used to launch the main app at login.
@MainActor
final class LoginItemService {
    enum UpdateResult {
        case success
        case requiresApproval
        case unavailable(String)
        case failure(String)
    }

    private var unsupportedMessage: String {
        L10n.text("automation.unsupported", fallback: "Open at login requires macOS 13 or later.")
    }

    var isSupported: Bool {
        if #available(macOS 13.0, *) {
            return true
        }

        return false
    }

    var isEnabled: Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }

        return false
    }

    var statusDescription: String {
        if #available(macOS 13.0, *) {
            switch SMAppService.mainApp.status {
            case .enabled:
                return L10n.text(
                    "automation.enabled",
                    fallback: "The app will open automatically when you log in."
                )
            case .requiresApproval:
                return L10n.text(
                    "automation.requiresApproval",
                    fallback: "macOS requires approval in System Settings before the app can open at login."
                )
            case .notRegistered:
                return L10n.text(
                    "automation.notRegistered",
                    fallback: "The app is not configured to open at login."
                )
            case .notFound:
                return L10n.text(
                    "automation.notFound",
                    fallback: "macOS could not find the login item registration for this app."
                )
            @unknown default:
                return L10n.text(
                    "automation.unknown",
                    fallback: "The login item status could not be determined."
                )
            }
        }

        return unsupportedMessage
    }

    func refreshState() -> (enabled: Bool, description: String) {
        (isEnabled, statusDescription)
    }

    func setEnabled(_ enabled: Bool) -> UpdateResult {
        guard #available(macOS 13.0, *) else {
            return .unavailable(unsupportedMessage)
        }

        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            return .failure(error.localizedDescription)
        }

        switch SMAppService.mainApp.status {
        case .enabled, .notRegistered:
            return .success
        case .requiresApproval:
            return .requiresApproval
        case .notFound:
            return .failure(
                L10n.text("notice.loginNotFound", fallback: "macOS could not find the login item service.")
            )
        @unknown default:
            return .failure(
                L10n.text(
                    "notice.loginUnknown",
                    fallback: "macOS returned an unexpected login item status."
                )
            )
        }
    }
}

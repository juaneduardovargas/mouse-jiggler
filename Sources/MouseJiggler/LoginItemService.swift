import Foundation
import ServiceManagement

@MainActor
final class LoginItemService {
    enum UpdateResult {
        case success
        case requiresApproval
        case unavailable(String)
        case failure(String)
    }

    private let unsupportedMessage = "Abrir al iniciar sesion requiere macOS 13 o superior."

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
                return "Abrira automaticamente al iniciar sesion."
            case .requiresApproval:
                return "macOS requiere aprobacion en Ajustes para abrir al iniciar sesion."
            case .notRegistered:
                return "No esta configurada para abrir al iniciar sesion."
            case .notFound:
                return "macOS no encontro el registro de inicio de sesion para esta app."
            @unknown default:
                return "El estado de inicio de sesion no pudo determinarse."
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
            return .failure("macOS no encontro el servicio de inicio de sesion.")
        @unknown default:
            return .failure("macOS devolvio un estado inesperado para el inicio de sesion.")
        }
    }
}

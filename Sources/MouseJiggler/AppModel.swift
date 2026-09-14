import AppKit
import ApplicationServices
import Foundation

@MainActor
final class AppModel: ObservableObject {
    static let shared = AppModel()

    @Published private(set) var intervalSeconds: Double
    @Published private(set) var isRunning = false
    @Published private(set) var hasAccessibilityPermission: Bool
    @Published private(set) var lastJiggleAt: Date?
    @Published private(set) var startJigglingOnLaunch: Bool
    @Published private(set) var launchAtLoginEnabled: Bool
    @Published private(set) var launchAtLoginDescription: String
    @Published private(set) var noticeMessage: String?

    private let jigglerService = JigglerService()
    private let loginItemService = LoginItemService()
    private var timer: Timer?

    private let minimumInterval: Double = 0.5
    private let maximumInterval: Double = 3600
    private let intervalKey = "mouseJiggler.intervalSeconds"
    private let startJigglingOnLaunchKey = "mouseJiggler.startJigglingOnLaunch"

    private init() {
        let storedInterval = UserDefaults.standard.object(forKey: intervalKey) as? Double
        intervalSeconds = Self.clamp(storedInterval ?? 1, minimum: 0.5, maximum: 3600)
        startJigglingOnLaunch = UserDefaults.standard.bool(forKey: startJigglingOnLaunchKey)
        hasAccessibilityPermission = Self.isAccessibilityTrusted(prompt: false)
        let launchAtLoginState = loginItemService.refreshState()
        launchAtLoginEnabled = launchAtLoginState.enabled
        launchAtLoginDescription = launchAtLoginState.description
    }

    var formattedInterval: String {
        intervalSeconds.formatted(.number.precision(.fractionLength(0 ... 1)))
    }

    var activityMessage: String {
        if isRunning {
            if let lastJiggleAt {
                return "Activo. Ultimo movimiento: \(lastJiggleAt.formatted(date: .omitted, time: .standard))."
            }

            return "Activo. Intervalo actual: \(formattedInterval) s."
        }

        return "Detenido. Intervalo configurado: \(formattedInterval) s."
    }

    var lastJiggleDescription: String {
        guard let lastJiggleAt else {
            return "Sin movimientos todavia."
        }

        return "Ultimo movimiento: \(lastJiggleAt.formatted(date: .omitted, time: .standard))."
    }

    var permissionMessage: String {
        if hasAccessibilityPermission {
            return "Permiso de Accesibilidad concedido."
        }

        return "macOS necesita permiso de Accesibilidad para mover el cursor."
    }

    func setInterval(_ newValue: Double) {
        let clamped = Self.clamp(newValue, minimum: minimumInterval, maximum: maximumInterval)
        guard clamped != intervalSeconds else { return }

        intervalSeconds = clamped
        UserDefaults.standard.set(clamped, forKey: intervalKey)

        if isRunning {
            scheduleTimer()
        }
    }

    func toggleRunning() {
        isRunning ? stop() : start()
    }

    func setStartJigglingOnLaunch(_ newValue: Bool) {
        startJigglingOnLaunch = newValue
        UserDefaults.standard.set(newValue, forKey: startJigglingOnLaunchKey)
    }

    func setLaunchAtLogin(_ newValue: Bool) {
        switch loginItemService.setEnabled(newValue) {
        case .success:
            break
        case .requiresApproval:
            noticeMessage = "macOS necesita aprobacion para abrir la app al iniciar sesion."
        case .unavailable(let message), .failure(let message):
            noticeMessage = message
        }

        refreshLaunchAtLoginStatus()
    }

    func start() {
        refreshAccessibilityStatus(prompt: true)
        guard hasAccessibilityPermission else {
            noticeMessage = "Concede Accesibilidad para que la app pueda mover el cursor."
            return
        }

        isRunning = true
        jiggleNow(promptForPermission: false)
        scheduleTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func refreshAccessibilityStatus(prompt: Bool = false) {
        hasAccessibilityPermission = Self.isAccessibilityTrusted(prompt: prompt)

        if !hasAccessibilityPermission, isRunning {
            stop()
        }
    }

    func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }

        NSWorkspace.shared.open(url)
    }

    func quitApp() {
        stop()
        NSApp.terminate(nil)
    }

    func refreshLaunchAtLoginStatus() {
        let state = loginItemService.refreshState()
        launchAtLoginEnabled = state.enabled
        launchAtLoginDescription = state.description
    }

    func clearNotice() {
        noticeMessage = nil
    }

    private func scheduleTimer() {
        timer?.invalidate()

        let timer = Timer(timeInterval: intervalSeconds, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.jiggleNow(promptForPermission: false)
            }
        }

        timer.tolerance = min(intervalSeconds * 0.1, 0.25)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func jiggleNow(promptForPermission: Bool) {
        refreshAccessibilityStatus(prompt: promptForPermission)
        guard hasAccessibilityPermission else {
            noticeMessage = "No hay permiso de Accesibilidad para mover el cursor."
            return
        }

        if jigglerService.jiggle() {
            lastJiggleAt = Date()
            noticeMessage = nil
            return
        }

        noticeMessage = "No se pudo enviar el movimiento del cursor."
        stop()
    }

    private static func isAccessibilityTrusted(prompt: Bool) -> Bool {
        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [promptKey: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    private static func clamp(_ value: Double, minimum: Double, maximum: Double) -> Double {
        min(max(value, minimum), maximum)
    }
}

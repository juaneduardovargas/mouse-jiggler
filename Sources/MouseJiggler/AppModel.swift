import AppKit
import ApplicationServices
import Foundation

/// Owns the application state and coordinates cursor movement, permissions, and preferences.
@MainActor
final class AppModel: ObservableObject {
    static let shared = AppModel()

    // MARK: - Observable state

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

    // MARK: - Lifecycle

    private init() {
        let storedInterval = UserDefaults.standard.object(forKey: intervalKey) as? Double
        intervalSeconds = Self.clamp(storedInterval ?? 1, minimum: 0.5, maximum: 3600)
        startJigglingOnLaunch = UserDefaults.standard.bool(forKey: startJigglingOnLaunchKey)
        hasAccessibilityPermission = Self.isAccessibilityTrusted(prompt: false)
        let launchAtLoginState = loginItemService.refreshState()
        launchAtLoginEnabled = launchAtLoginState.enabled
        launchAtLoginDescription = launchAtLoginState.description
    }

    // MARK: - Display values

    var formattedInterval: String {
        intervalSeconds.formatted(.number.precision(.fractionLength(0 ... 1)))
    }

    var activityMessage: String {
        if isRunning {
            if let lastJiggleAt {
                return L10n.format(
                    "activity.running.last",
                    fallback: "Running. Last movement: %@.",
                    lastJiggleAt.formatted(date: .omitted, time: .standard)
                )
            }

            return L10n.format(
                "activity.running.interval",
                fallback: "Running. Current interval: %@ s.",
                formattedInterval
            )
        }

        return L10n.format(
            "activity.stopped.interval",
            fallback: "Stopped. Configured interval: %@ s.",
            formattedInterval
        )
    }

    var lastJiggleDescription: String {
        guard let lastJiggleAt else {
            return L10n.text("menu.lastMovement.none", fallback: "No movements yet.")
        }

        return L10n.format(
            "menu.lastMovement",
            fallback: "Last movement: %@.",
            lastJiggleAt.formatted(date: .omitted, time: .standard)
        )
    }

    var permissionMessage: String {
        if hasAccessibilityPermission {
            return L10n.text("permission.granted", fallback: "Accessibility permission granted.")
        }

        return L10n.text(
            "permission.required",
            fallback: "macOS needs Accessibility permission to move the cursor."
        )
    }

    // MARK: - Preferences

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
            noticeMessage = L10n.text(
                "notice.launchApproval",
                fallback: "macOS requires approval before the app can open at login."
            )
        case .unavailable(let message), .failure(let message):
            noticeMessage = message
        }

        refreshLaunchAtLoginStatus()
    }

    // MARK: - Jiggler controls

    func start() {
        refreshAccessibilityStatus(prompt: true)
        guard hasAccessibilityPermission else {
            noticeMessage = L10n.text(
                "notice.accessibilityRequired",
                fallback: "Grant Accessibility permission so the app can move the cursor."
            )
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

    /// Refreshes macOS Accessibility authorization and stops movement if access was revoked.
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

    /// Performs one movement cycle and optionally asks macOS to show the permission prompt.
    func jiggleNow(promptForPermission: Bool) {
        refreshAccessibilityStatus(prompt: promptForPermission)
        guard hasAccessibilityPermission else {
            noticeMessage = L10n.text(
                "notice.accessibilityMissing",
                fallback: "Accessibility permission is required to move the cursor."
            )
            return
        }

        if jigglerService.jiggle() {
            lastJiggleAt = Date()
            noticeMessage = nil
            return
        }

        noticeMessage = L10n.text(
            "notice.jiggleFailed",
            fallback: "The cursor movement could not be sent."
        )
        stop()
    }

    // MARK: - Timer and permissions

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

    private static func isAccessibilityTrusted(prompt: Bool) -> Bool {
        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [promptKey: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    private static func clamp(_ value: Double, minimum: Double, maximum: Double) -> Double {
        min(max(value, minimum), maximum)
    }
}

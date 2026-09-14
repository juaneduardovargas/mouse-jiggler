import AppKit

/// Owns the persistent macOS menu bar item and its quick-action menu.
@MainActor
final class StatusItemController: NSObject {
    private let appModel: AppModel
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let statusItemMenuEntry = NSMenuItem()
    private let lastMovementItem = NSMenuItem()
    private let toggleRunningItem = NSMenuItem()
    private let openPanelItem = NSMenuItem()
    private let jiggleNowItem = NSMenuItem()
    private let startOnLaunchItem = NSMenuItem()
    private let launchAtLoginItem = NSMenuItem()
    private let intervalItem = NSMenuItem()
    private let permissionItem = NSMenuItem()
    private let versionItem = NSMenuItem()
    private let quitItem = NSMenuItem()

    var onOpenPanel: (() -> Void)?
    var onToggleRunning: (() -> Void)?
    var onJiggleNow: (() -> Void)?
    var onToggleStartOnLaunch: (() -> Void)?
    var onToggleLaunchAtLogin: (() -> Void)?
    var onQuit: (() -> Void)?

    init(appModel: AppModel) {
        self.appModel = appModel
        super.init()
        configureStatusItem()
        configureMenu()
        refresh()
    }

    /// Synchronizes every menu title and indicator with the latest model state.
    func refresh() {
        statusItem.button?.image = StatusIconRenderer.make(isRunning: appModel.isRunning)
        statusItem.button?.title = appModel.isRunning
            ? L10n.text("status.active.short", fallback: " Active")
            : L10n.text("status.inactive.short", fallback: " Inactive")
        statusItem.button?.toolTip = L10n.text("app.name", fallback: "Mouse Jiggler")

        statusItemMenuEntry.title = appModel.isRunning
            ? L10n.text("status.active", fallback: "Status: Active")
            : L10n.text("status.inactive", fallback: "Status: Inactive")
        lastMovementItem.title = appModel.lastJiggleDescription
        toggleRunningItem.title = appModel.isRunning
            ? L10n.text("menu.stop", fallback: "Stop movement")
            : L10n.text("menu.start", fallback: "Start movement")
        openPanelItem.title = L10n.text("menu.openPanel", fallback: "Open control panel")
        jiggleNowItem.title = L10n.text("button.jiggleNow", fallback: "Move now")
        startOnLaunchItem.title = L10n.text(
            "menu.startJiggling",
            fallback: "Start movement when the app opens"
        )
        startOnLaunchItem.state = appModel.startJigglingOnLaunch ? .on : .off
        launchAtLoginItem.title = L10n.text("menu.launchAtLogin", fallback: "Open the app at login")
        launchAtLoginItem.state = appModel.launchAtLoginEnabled ? .on : .off
        intervalItem.title = L10n.format(
            "menu.interval",
            fallback: "Interval: %@ s",
            appModel.formattedInterval
        )
        permissionItem.title = appModel.hasAccessibilityPermission
            ? L10n.text("permission.menu.granted", fallback: "Accessibility: OK")
            : L10n.text("permission.menu.pending", fallback: "Accessibility: Pending")

        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        versionItem.title = L10n.format("menu.version", fallback: "Version %@", version)
        quitItem.title = L10n.text("common.quit", fallback: "Quit")
    }

    // MARK: - Setup

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }

        button.imagePosition = .imageLeading
        statusItem.menu = menu
    }

    // MARK: - Actions

    private func configureMenu() {
        statusItemMenuEntry.isEnabled = false
        lastMovementItem.isEnabled = false

        toggleRunningItem.target = self
        toggleRunningItem.action = #selector(toggleRunning)

        openPanelItem.target = self
        openPanelItem.action = #selector(openPanel)

        jiggleNowItem.target = self
        jiggleNowItem.action = #selector(jiggleNow)

        startOnLaunchItem.target = self
        startOnLaunchItem.action = #selector(toggleStartOnLaunch)

        launchAtLoginItem.target = self
        launchAtLoginItem.action = #selector(toggleLaunchAtLogin)

        intervalItem.isEnabled = false
        permissionItem.isEnabled = false
        versionItem.isEnabled = false

        quitItem.target = self
        quitItem.action = #selector(quitApp)

        menu.autoenablesItems = false
        menu.items = [
            statusItemMenuEntry,
            lastMovementItem,
            .separator(),
            toggleRunningItem,
            jiggleNowItem,
            .separator(),
            openPanelItem,
            startOnLaunchItem,
            launchAtLoginItem,
            intervalItem,
            permissionItem,
            versionItem,
            .separator(),
            quitItem
        ]
    }

    @objc
    private func toggleRunning() {
        onToggleRunning?()
    }

    @objc
    private func openPanel() {
        onOpenPanel?()
    }

    @objc
    private func jiggleNow() {
        onJiggleNow?()
    }

    @objc
    private func toggleStartOnLaunch() {
        onToggleStartOnLaunch?()
    }

    @objc
    private func toggleLaunchAtLogin() {
        onToggleLaunchAtLogin?()
    }

    @objc
    private func quitApp() {
        onQuit?()
    }
}

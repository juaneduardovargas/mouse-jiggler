import AppKit

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

    func refresh() {
        statusItem.button?.image = StatusIconRenderer.make(isRunning: appModel.isRunning)
        statusItem.button?.title = appModel.isRunning ? " Activo" : " Inactivo"
        statusItem.button?.toolTip = "Mouse Jiggler"

        statusItemMenuEntry.title = appModel.isRunning ? "Estado: Activo" : "Estado: Inactivo"
        lastMovementItem.title = appModel.lastJiggleDescription
        toggleRunningItem.title = appModel.isRunning ? "Detener movimiento" : "Iniciar movimiento"
        openPanelItem.title = "Abrir panel"
        jiggleNowItem.title = "Mover ahora"
        startOnLaunchItem.title = "Iniciar movimiento al abrir la app"
        startOnLaunchItem.state = appModel.startJigglingOnLaunch ? .on : .off
        launchAtLoginItem.title = "Abrir la app al iniciar sesion"
        launchAtLoginItem.state = appModel.launchAtLoginEnabled ? .on : .off
        intervalItem.title = "Intervalo: \(appModel.formattedInterval) s"
        permissionItem.title = appModel.hasAccessibilityPermission ? "Accesibilidad: OK" : "Accesibilidad: pendiente"
        versionItem.title = "Version 1.0"
        quitItem.title = "Salir"
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }

        button.imagePosition = .imageLeading
        statusItem.menu = menu
    }

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

import AppKit
import Combine
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appModel = AppModel.shared
    private var statusItemController: StatusItemController?
    private var controlWindowController: ControlWindowController?
    private var cancellables = Set<AnyCancellable>()
    private let didPresentWindowKey = "mouseJiggler.didPresentWindow"

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        controlWindowController = ControlWindowController(appModel: appModel)
        statusItemController = StatusItemController(appModel: appModel)

        statusItemController?.onOpenPanel = { [weak self] in
            self?.controlWindowController?.showWindowAndActivate()
        }

        statusItemController?.onToggleRunning = { [weak self] in
            self?.appModel.toggleRunning()
            self?.statusItemController?.refresh()
        }

        statusItemController?.onJiggleNow = { [weak self] in
            self?.appModel.jiggleNow(promptForPermission: true)
            self?.statusItemController?.refresh()
        }

        statusItemController?.onToggleStartOnLaunch = { [weak self] in
            guard let self else { return }
            self.appModel.setStartJigglingOnLaunch(!self.appModel.startJigglingOnLaunch)
            self.statusItemController?.refresh()
        }

        statusItemController?.onToggleLaunchAtLogin = { [weak self] in
            guard let self else { return }
            self.appModel.setLaunchAtLogin(!self.appModel.launchAtLoginEnabled)
            self.statusItemController?.refresh()
        }

        statusItemController?.onQuit = { [weak self] in
            self?.appModel.quitApp()
        }

        observeModel()
        presentWindowOnFirstLaunch()
        appModel.refreshLaunchAtLoginStatus()

        if appModel.startJigglingOnLaunch {
            appModel.start()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        controlWindowController?.showWindowAndActivate()
        return true
    }

    private func observeModel() {
        appModel.$isRunning
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.statusItemController?.refresh()
            }
            .store(in: &cancellables)

        appModel.$hasAccessibilityPermission
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.statusItemController?.refresh()
            }
            .store(in: &cancellables)

        appModel.$intervalSeconds
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.statusItemController?.refresh()
            }
            .store(in: &cancellables)

        appModel.$launchAtLoginEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.statusItemController?.refresh()
            }
            .store(in: &cancellables)

        appModel.$lastJiggleAt
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.statusItemController?.refresh()
            }
            .store(in: &cancellables)

        appModel.$startJigglingOnLaunch
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.statusItemController?.refresh()
            }
            .store(in: &cancellables)
    }

    private func presentWindowOnFirstLaunch() {
        guard !UserDefaults.standard.bool(forKey: didPresentWindowKey) else { return }

        UserDefaults.standard.set(true, forKey: didPresentWindowKey)
        controlWindowController?.showWindowAndActivate()
    }
}

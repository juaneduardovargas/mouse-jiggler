import AppKit
import SwiftUI

@MainActor
final class ControlWindowController: NSWindowController, NSWindowDelegate {
    init(appModel: AppModel) {
        let rootView = ControlPanelView()
            .environmentObject(appModel)

        let hostingView = NSHostingView(rootView: rootView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        let contentViewController = NSViewController()
        contentViewController.view = NSView(frame: NSRect(x: 0, y: 0, width: 410, height: 460))
        contentViewController.view.addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: contentViewController.view.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: contentViewController.view.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: contentViewController.view.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: contentViewController.view.bottomAnchor)
        ])

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 410, height: 460),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.contentViewController = contentViewController
        window.title = "Mouse Jiggler"
        window.center()
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.moveToActiveSpace]

        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) no esta soportado")
    }

    func toggleVisibility() {
        guard let window else { return }

        if window.isVisible {
            window.orderOut(nil)
            return
        }

        showWindowAndActivate()
    }

    func showWindowAndActivate() {
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

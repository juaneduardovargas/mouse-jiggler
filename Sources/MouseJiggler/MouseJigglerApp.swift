import SwiftUI

/// SwiftUI entry point. AppKit owns the status item and control window lifecycle.
@main
struct MouseJigglerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

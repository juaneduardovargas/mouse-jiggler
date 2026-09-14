import SwiftUI

/// Main control panel for status, interval, automation, and permissions.
struct ControlPanelView: View {
    @EnvironmentObject private var appModel: AppModel

    private var intervalBinding: Binding<Double> {
        Binding(
            get: { appModel.intervalSeconds },
            set: { appModel.setInterval($0) }
        )
    }

    private var startOnLaunchBinding: Binding<Bool> {
        Binding(
            get: { appModel.startJigglingOnLaunch },
            set: { appModel.setStartJigglingOnLaunch($0) }
        )
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { appModel.launchAtLoginEnabled },
            set: { appModel.setLaunchAtLogin($0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            noticeCard
            intervalCard
            automationCard
            permissionCard
            actions
        }
        .padding(18)
        .frame(width: 430)
        .onAppear {
            appModel.refreshAccessibilityStatus()
        }
    }

    @ViewBuilder
    private var noticeCard: some View {
        if let noticeMessage = appModel.noticeMessage {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(L10n.text("notice.title", fallback: "Notice"))
                        .font(.headline)

                    Spacer()

                    Button(L10n.text("common.close", fallback: "Close")) {
                        appModel.clearNotice()
                    }
                    .buttonStyle(.borderless)
                }

                Text(noticeMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.08, green: 0.18, blue: 0.35),
                                Color(red: 0.03, green: 0.53, blue: 0.67)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "cursorarrow")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.text("app.name", fallback: "Mouse Jiggler"))
                    .font(.system(size: 18, weight: .semibold))

                Text(
                    appModel.isRunning
                        ? L10n.text("status.running", fallback: "Running")
                        : L10n.text("status.ready", fallback: "Ready to start")
                )
                    .font(.callout)
                    .foregroundStyle(appModel.isRunning ? .green : .secondary)

                Text(appModel.activityMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }

    private var intervalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.text("interval.title", fallback: "Interval"))
                .font(.headline)

            HStack(spacing: 10) {
                TextField(
                    L10n.text("interval.placeholder", fallback: "Seconds"),
                    value: intervalBinding,
                    format: .number.precision(.fractionLength(0 ... 1))
                )
                .textFieldStyle(.roundedBorder)
                .frame(width: 90)

                Text(L10n.text("interval.unit", fallback: "seconds"))
                    .foregroundStyle(.secondary)

                Spacer()

                Stepper("", value: intervalBinding, in: 0.5 ... 3600, step: 0.5)
                    .labelsHidden()
            }

            Slider(value: intervalBinding, in: 0.5 ... 60, step: 0.5)

            HStack(spacing: 8) {
                presetButton(1)
                presetButton(5)
                presetButton(30)
                Spacer()
            }

            Text(
                L10n.text(
                    "interval.help",
                    fallback: "The quick control ranges from 0.5 to 60 seconds. Enter a value manually for a longer interval."
                )
            )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var automationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.text("automation.title", fallback: "Automation"))
                .font(.headline)

            Toggle(
                L10n.text("automation.startJiggling", fallback: "Start movement when the app opens"),
                isOn: startOnLaunchBinding
            )

            Toggle(
                L10n.text("automation.launchAtLogin", fallback: "Open the app when you log in to macOS"),
                isOn: launchAtLoginBinding
            )

            Text(appModel.launchAtLoginDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(
                L10n.text(
                    "automation.help",
                    fallback: "Use the menu bar indicator to access these controls at any time."
                )
            )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var permissionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Circle()
                    .fill(appModel.hasAccessibilityPermission ? Color.green : Color.orange)
                    .frame(width: 10, height: 10)

                Text(L10n.text("permissions.title", fallback: "Permissions"))
                    .font(.headline)
            }

            Text(appModel.permissionMessage)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(L10n.text("button.openAccessibility", fallback: "Open Accessibility Settings")) {
                appModel.openAccessibilitySettings()
            }
            .buttonStyle(.bordered)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Button(
                    appModel.isRunning
                        ? L10n.text("button.stop", fallback: "Stop")
                        : L10n.text("button.start", fallback: "Start")
                ) {
                    appModel.toggleRunning()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button(L10n.text("button.jiggleNow", fallback: "Move now")) {
                    appModel.jiggleNow(promptForPermission: true)
                }
                .buttonStyle(.bordered)

                Spacer()
            }

            HStack(spacing: 10) {
                Button(L10n.text("button.refreshPermissions", fallback: "Refresh permissions")) {
                    appModel.refreshAccessibilityStatus(prompt: false)
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(L10n.text("common.quit", fallback: "Quit")) {
                    appModel.quitApp()
                }
                .buttonStyle(.borderless)
            }
        }
    }

    private func presetButton(_ seconds: Double) -> some View {
        Button(L10n.format("interval.preset", fallback: "%d s", Int(seconds))) {
            appModel.setInterval(seconds)
        }
        .buttonStyle(.bordered)
    }
}

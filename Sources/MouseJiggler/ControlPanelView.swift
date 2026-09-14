import SwiftUI

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
        .frame(width: 390)
        .onAppear {
            appModel.refreshAccessibilityStatus()
        }
    }

    @ViewBuilder
    private var noticeCard: some View {
        if let noticeMessage = appModel.noticeMessage {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Aviso")
                        .font(.headline)

                    Spacer()

                    Button("Cerrar") {
                        appModel.clearNotice()
                    }
                    .buttonStyle(.borderless)
                }

                Text(noticeMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
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
                Text("Mouse Jiggler")
                    .font(.system(size: 18, weight: .semibold))

                Text(appModel.isRunning ? "En ejecucion" : "Listo para iniciar")
                    .font(.callout)
                    .foregroundStyle(appModel.isRunning ? .green : .secondary)

                Text(appModel.activityMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
    }

    private var intervalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Intervalo")
                .font(.headline)

            HStack(spacing: 10) {
                TextField(
                    "Segundos",
                    value: intervalBinding,
                    format: .number.precision(.fractionLength(0 ... 1))
                )
                .textFieldStyle(.roundedBorder)
                .frame(width: 90)

                Text("segundos")
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

            Text("El control rapido va de 0.5 a 60 segundos. Si quieres mas tiempo, escribelo manualmente.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var automationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Automatizacion")
                .font(.headline)

            Toggle("Iniciar movimiento al abrir la app", isOn: startOnLaunchBinding)

            Toggle("Abrir la app al iniciar sesion en macOS", isOn: launchAtLoginBinding)

            Text(appModel.launchAtLoginDescription)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Haz clic en el icono de la barra superior para abrir o cerrar este panel cuando quieras.")
                .font(.caption)
                .foregroundStyle(.secondary)
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

                Text("Permisos")
                    .font(.headline)
            }

            Text(appModel.permissionMessage)
                .font(.callout)
                .foregroundStyle(.secondary)

            Button("Abrir Ajustes de Accesibilidad") {
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
                Button(appModel.isRunning ? "Detener" : "Iniciar") {
                    appModel.toggleRunning()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("Mover ahora") {
                    appModel.jiggleNow(promptForPermission: true)
                }
                .buttonStyle(.bordered)

                Spacer()
            }

            HStack(spacing: 10) {
                Button("Actualizar permisos") {
                    appModel.refreshAccessibilityStatus(prompt: false)
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Salir") {
                    appModel.quitApp()
                }
                .buttonStyle(.borderless)
            }
        }
    }

    private func presetButton(_ seconds: Double) -> some View {
        Button("\(Int(seconds)) s") {
            appModel.setInterval(seconds)
        }
        .buttonStyle(.bordered)
    }
}

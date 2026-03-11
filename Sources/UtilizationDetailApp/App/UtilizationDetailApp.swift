import AppKit
import SwiftUI

@main
struct UtilizationDetailApp: App {
    @State private var model = UtilizationDashboardModel()

    init() {
        NSApplication.shared.setActivationPolicy(.regular)
        if let image = utilizationAppIconImage() {
            NSApplication.shared.applicationIconImage = image
        }
    }

    var body: some Scene {
        WindowGroup("Utilization Detail") {
            UtilizationDashboardView(model: model)
                .frame(minWidth: 1100, minHeight: 760)
                .task {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
        }
        .defaultSize(width: 1500, height: 920)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Refresh Telemetry", action: model.refreshNow)
                    .keyboardShortcut("r")

                Button("Per Core View") {
                    model.displayMode = .perCore
                }
                .keyboardShortcut("1")

                Button("Cluster View") {
                    model.displayMode = .cluster
                }
                .keyboardShortcut("2")
            }
        }
    }
}

private func utilizationAppIconImage() -> NSImage? {
    guard let url = Bundle.module.url(forResource: "AppIcon-1024", withExtension: "png") else {
        return nil
    }

    return NSImage(contentsOf: url)
}

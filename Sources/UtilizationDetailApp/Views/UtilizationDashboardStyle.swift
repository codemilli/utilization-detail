import SwiftUI

enum UtilizationDashboardStyle {
    static let pagePadding = 32.0
    static let sectionSpacing = 28.0
    static let cardSpacing = 18.0
    static let cardCornerRadius = 18.0
    static let panelCornerRadius = 26.0
    static let cardMinimumWidth = 168.0
    static let cardMaximumWidth = 210.0
    static let clusterMinimumWidth = 300.0
    static let clusterMaximumWidth = 420.0
    static let chartHeight = 96.0
    static let headerChartHeight = 132.0

    static let pageBackground = Color(nsColor: .windowBackgroundColor)
    static let panelBackground = Color.white.opacity(0.74)
    static let subtleFill = Color.black.opacity(0.025)
    static let panelStroke = Color.black.opacity(0.08)
    static let labelColor = Color.secondary

    static func tint(for kind: CPUCoreKind) -> Color {
        switch kind {
        case .superCore:
            Color(red: 0.78, green: 0.42, blue: 0.96)
        case .efficiency:
            Color(red: 0.26, green: 0.76, blue: 0.63)
        case .performance:
            Color(red: 0.31, green: 0.62, blue: 0.96)
        }
    }

    static func cardFill(for kind: CPUCoreKind) -> Color {
        tint(for: kind).opacity(0.06)
    }
}

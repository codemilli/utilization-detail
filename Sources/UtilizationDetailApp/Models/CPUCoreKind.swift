import Foundation

enum CPUCoreKind: String, CaseIterable, Sendable {
    case superCore
    case performance
    case efficiency

    var shortLabel: String {
        switch self {
        case .superCore:
            "S"
        case .efficiency:
            "E"
        case .performance:
            "P"
        }
    }

    var sectionTitle: String {
        switch self {
        case .superCore:
            "S-CORES"
        case .efficiency:
            "E-CORES"
        case .performance:
            "P-CORES"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .superCore:
            "super"
        case .efficiency:
            "efficiency"
        case .performance:
            "performance"
        }
    }

    var sortOrder: Int {
        switch self {
        case .superCore:
            0
        case .performance:
            1
        case .efficiency:
            2
        }
    }
}

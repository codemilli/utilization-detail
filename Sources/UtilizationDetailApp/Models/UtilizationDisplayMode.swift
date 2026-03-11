import Foundation

enum UtilizationDisplayMode: String, CaseIterable, Identifiable, Sendable {
    case cluster
    case perCore

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cluster:
            "Cluster"
        case .perCore:
            "Per Core"
        }
    }

    var subtitle: String {
        switch self {
        case .cluster:
            "Cluster rollups"
        case .perCore:
            "Per-core traces"
        }
    }
}

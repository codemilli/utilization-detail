import Foundation

struct CPUCoreMetric: Identifiable, Equatable, Sendable {
    let id: String
    let cpuIndex: Int
    let kind: CPUCoreKind
    let ordinal: Int
    var samples: [Double]
    var latestTimestamp: Date
    var currentUtilization: Double
    var peakUtilization: Double
}

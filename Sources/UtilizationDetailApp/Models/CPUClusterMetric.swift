import Foundation

struct CPUClusterMetric: Identifiable, Equatable, Sendable {
    let id: String
    let kind: CPUCoreKind
    let coreCount: Int
    let currentUtilization: Double
    let peakUtilization: Double
    let latestTimestamp: Date
    let samples: [Double]

    init?(kind: CPUCoreKind, metrics: [CPUCoreMetric]) {
        guard !metrics.isEmpty else { return nil }

        let sampleCount = metrics.map(\.samples.count).max() ?? 0
        let aggregatedSamples: [Double] = (0..<sampleCount).map { index in
            let values = metrics.compactMap { metric -> Double? in
                guard metric.samples.indices.contains(index) else { return nil }
                return metric.samples[index]
            }

            guard !values.isEmpty else { return 0.0 }
            return values.reduce(0, +) / Double(values.count)
        }

        id = kind.rawValue
        self.kind = kind
        coreCount = metrics.count
        currentUtilization = metrics.map(\.currentUtilization).reduce(0, +) / Double(metrics.count)
        peakUtilization = metrics.map(\.peakUtilization).max() ?? 0
        latestTimestamp = metrics.map(\.latestTimestamp).max() ?? .now
        samples = aggregatedSamples
    }
}

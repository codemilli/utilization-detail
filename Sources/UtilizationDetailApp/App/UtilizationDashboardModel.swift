import Foundation
import Observation

@MainActor
@Observable
final class UtilizationDashboardModel {
    var displayMode: UtilizationDisplayMode = .perCore
    var deviceName = "Apple Silicon"
    var coreMetrics: [CPUCoreMetric] = []
    var lastUpdated: Date?
    var isLiveTelemetry = false
    var refreshIntervalSeconds = 0.9

    @ObservationIgnored private let historyLimit = 48
    @ObservationIgnored private let telemetryProvider: LiveCPUTelemetryProvider
    @ObservationIgnored private var samplingTask: Task<Void, Never>?

    init(telemetryProvider: LiveCPUTelemetryProvider = .init()) {
        self.telemetryProvider = telemetryProvider
        refreshNow()
    }

    var efficiencyMetrics: [CPUCoreMetric] {
        coreMetrics.filter { $0.kind == .efficiency }
    }

    var superMetrics: [CPUCoreMetric] {
        coreMetrics.filter { $0.kind == .superCore }
    }

    var performanceMetrics: [CPUCoreMetric] {
        coreMetrics.filter { $0.kind == .performance }
    }

    var clusterMetrics: [CPUClusterMetric] {
        CPUCoreKind.allCases.compactMap { kind in
            let metrics = coreMetrics.filter { $0.kind == kind }
            return CPUClusterMetric(kind: kind, metrics: metrics)
        }
    }

    var chartSummary: String {
        let segments = CPUCoreKind.allCases.compactMap { kind -> String? in
            let count = metrics(for: kind).count
            guard count > 0 else { return nil }
            return "\(kind.shortLabel) \(count)"
        }

        guard !segments.isEmpty else {
            return "\(coreMetrics.count) charts"
        }

        return "\(coreMetrics.count) charts | " + segments.joined(separator: " | ")
    }

    var telemetryFootnote: String {
        if isLiveTelemetry {
            return "Native live telemetry via host_processor_info and sysctl."
        }

        return "Preview telemetry is shown until live deltas stabilize."
    }

    func startSampling() {
        guard samplingTask == nil else { return }

        samplingTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(Int(self.refreshIntervalSeconds * 1_000)))
                self.refreshNow()
            }
        }
    }

    func stopSampling() {
        samplingTask?.cancel()
        samplingTask = nil
    }

    func refreshNow() {
        apply(snapshot: telemetryProvider.sample())
    }

    func metrics(for kind: CPUCoreKind) -> [CPUCoreMetric] {
        switch kind {
        case .superCore:
            superMetrics
        case .performance:
            performanceMetrics
        case .efficiency:
            efficiencyMetrics
        }
    }

    var activeKinds: [CPUCoreKind] {
        CPUCoreKind.allCases.filter { !metrics(for: $0).isEmpty }
    }

    private func apply(snapshot: CPUCoreTelemetrySnapshot) {
        deviceName = snapshot.device.deviceName
        coreMetrics = CPUCoreMetricsReducer.merge(
            snapshot,
            into: coreMetrics,
            historyLimit: historyLimit
        )
        lastUpdated = snapshot.timestamp
        isLiveTelemetry = snapshot.isLive
    }
}

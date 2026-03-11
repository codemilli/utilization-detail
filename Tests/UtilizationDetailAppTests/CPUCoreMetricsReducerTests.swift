import Foundation
import Testing
@testable import UtilizationDetailApp

struct CPUCoreMetricsReducerTests {
    @Test
    func sortsEfficiencyCoresBeforePerformanceCores() {
        let device = CPUDeviceDescriptor(
            deviceName: "Apple Test",
            cores: [
                CPUCoreDescriptor(id: "P1", cpuIndex: 0, kind: .performance, ordinal: 1),
                CPUCoreDescriptor(id: "E1", cpuIndex: 1, kind: .efficiency, ordinal: 1),
                CPUCoreDescriptor(id: "S1", cpuIndex: 2, kind: .superCore, ordinal: 1),
                CPUCoreDescriptor(id: "P2", cpuIndex: 3, kind: .performance, ordinal: 2),
            ]
        )

        let metrics = CPUCoreMetricsReducer.seed(
            device: device,
            timestamp: .now,
            historyLimit: 4
        )

        #expect(metrics.map(\.id) == ["S1", "P1", "P2", "E1"])
    }

    @Test
    func mergesLatestSamplesAndTrimsHistory() {
        let timestamp = Date(timeIntervalSince1970: 1_000)
        let laterTimestamp = Date(timeIntervalSince1970: 1_100)
        let device = CPUDeviceDescriptor(
            deviceName: "Apple Test",
            cores: [
                CPUCoreDescriptor(id: "E1", cpuIndex: 0, kind: .efficiency, ordinal: 1)
            ]
        )
        let seeded = CPUCoreMetricsReducer.seed(
            device: device,
            timestamp: timestamp,
            historyLimit: 3
        )
        let snapshot = CPUCoreTelemetrySnapshot(
            timestamp: laterTimestamp,
            device: device,
            utilizationsByCoreIndex: [0: 42.5],
            isLive: true
        )

        let merged = CPUCoreMetricsReducer.merge(
            snapshot,
            into: seeded,
            historyLimit: 3
        )

        #expect(merged.count == 1)
        #expect(merged[0].samples == [0, 0, 42.5])
        #expect(merged[0].currentUtilization == 42.5)
        #expect(merged[0].peakUtilization == 42.5)
        #expect(merged[0].latestTimestamp == laterTimestamp)
    }
}

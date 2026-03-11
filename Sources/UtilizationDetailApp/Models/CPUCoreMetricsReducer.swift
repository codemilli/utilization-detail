import Foundation

enum CPUCoreMetricsReducer {
    static func seed(
        device: CPUDeviceDescriptor,
        timestamp: Date,
        historyLimit: Int
    ) -> [CPUCoreMetric] {
        sortedDescriptors(device.cores).map { descriptor in
            CPUCoreMetric(
                id: descriptor.id,
                cpuIndex: descriptor.cpuIndex,
                kind: descriptor.kind,
                ordinal: descriptor.ordinal,
                samples: Array(repeating: 0, count: historyLimit),
                latestTimestamp: timestamp,
                currentUtilization: 0,
                peakUtilization: 0
            )
        }
    }

    static func merge(
        _ snapshot: CPUCoreTelemetrySnapshot,
        into existing: [CPUCoreMetric],
        historyLimit: Int
    ) -> [CPUCoreMetric] {
        let seeded = existing.isEmpty
            ? seed(device: snapshot.device, timestamp: snapshot.timestamp, historyLimit: historyLimit)
            : existing
        let existingByID = Dictionary(uniqueKeysWithValues: seeded.map { ($0.id, $0) })

        return sortedDescriptors(snapshot.device.cores).map { descriptor in
            let fallback = CPUCoreMetric(
                id: descriptor.id,
                cpuIndex: descriptor.cpuIndex,
                kind: descriptor.kind,
                ordinal: descriptor.ordinal,
                samples: Array(repeating: 0, count: historyLimit),
                latestTimestamp: snapshot.timestamp,
                currentUtilization: 0,
                peakUtilization: 0
            )

            var metric = existingByID[descriptor.id] ?? fallback
            let nextValue = clamped(snapshot.utilizationsByCoreIndex[descriptor.cpuIndex] ?? metric.currentUtilization)
            var samples = metric.samples
            samples.append(nextValue)

            if samples.count > historyLimit {
                samples.removeFirst(samples.count - historyLimit)
            }

            metric.samples = samples
            metric.latestTimestamp = snapshot.timestamp
            metric.currentUtilization = nextValue
            metric.peakUtilization = max(metric.peakUtilization, nextValue, samples.max() ?? 0)
            return metric
        }
    }

    static func sortedDescriptors(_ descriptors: [CPUCoreDescriptor]) -> [CPUCoreDescriptor] {
        descriptors.sorted { lhs, rhs in
            if lhs.kind.sortOrder != rhs.kind.sortOrder {
                return lhs.kind.sortOrder < rhs.kind.sortOrder
            }

            return lhs.ordinal < rhs.ordinal
        }
    }

    private static func clamped(_ utilization: Double) -> Double {
        min(max(utilization, 0), 100)
    }
}

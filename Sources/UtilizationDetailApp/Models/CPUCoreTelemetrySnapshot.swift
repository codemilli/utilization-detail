import Foundation

struct CPUCoreTelemetrySnapshot: Sendable {
    let timestamp: Date
    let device: CPUDeviceDescriptor
    let utilizationsByCoreIndex: [Int: Double]
    let isLive: Bool
}

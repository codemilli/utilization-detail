import Foundation

struct CPUDeviceDescriptor: Sendable {
    let deviceName: String
    let cores: [CPUCoreDescriptor]
}

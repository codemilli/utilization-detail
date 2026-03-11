import Foundation

struct CPUCoreDescriptor: Identifiable, Hashable, Sendable {
    let id: String
    let cpuIndex: Int
    let kind: CPUCoreKind
    let ordinal: Int
}

import Darwin
import Foundation

struct SystemCPUDescriptorReader {
    func read() -> CPUDeviceDescriptor {
        let deviceName = sysctlString("machdep.cpu.brand_string") ?? "Apple Silicon"
        let perfLevelCount = max(sysctlInt("hw.nperflevels") ?? 0, 0)

        if perfLevelCount > 0 {
            var nextCPUIndex = 0
            var descriptors: [CPUCoreDescriptor] = []
            var ordinals: [CPUCoreKind: Int] = [:]

            for level in 0..<perfLevelCount {
                let coreCount = max(sysctlInt("hw.perflevel\(level).physicalcpu") ?? 0, 0)
                let kind = kindForPerfLevel(named: sysctlString("hw.perflevel\(level).name"))

                guard coreCount > 0 else { continue }

                for _ in 0..<coreCount {
                    let ordinal = ordinals[kind, default: 0] + 1
                    ordinals[kind] = ordinal
                    descriptors.append(
                        CPUCoreDescriptor(
                            id: "\(kind.shortLabel)\(ordinal)",
                            cpuIndex: nextCPUIndex,
                            kind: kind,
                            ordinal: ordinal
                        )
                    )
                    nextCPUIndex += 1
                }
            }

            if !descriptors.isEmpty {
                return CPUDeviceDescriptor(deviceName: deviceName, cores: descriptors)
            }
        }

        let totalCoreCount = max(sysctlInt("hw.physicalcpu") ?? 1, 1)
        let descriptors = (0..<totalCoreCount).map { index in
            CPUCoreDescriptor(
                id: "P\(index + 1)",
                cpuIndex: index,
                kind: .performance,
                ordinal: index + 1
            )
        }

        return CPUDeviceDescriptor(deviceName: deviceName, cores: descriptors)
    }

    private func kindForPerfLevel(named name: String?) -> CPUCoreKind {
        guard let normalizedName = name?.lowercased() else {
            return .performance
        }

        if normalizedName.contains("super") {
            return .superCore
        }

        if normalizedName.contains("efficiency") {
            return .efficiency
        }

        return .performance
    }
}

private func sysctlInt(_ key: String) -> Int? {
    var value = Int32.zero
    var size = MemoryLayout<Int32>.size
    let result = key.withCString { pointer in
        sysctlbyname(pointer, &value, &size, nil, 0)
    }

    guard result == 0 else { return nil }
    return Int(value)
}

private func sysctlString(_ key: String) -> String? {
    var size = 0
    let sizeResult = key.withCString { pointer in
        sysctlbyname(pointer, nil, &size, nil, 0)
    }

    guard sizeResult == 0, size > 0 else { return nil }

    var buffer = [CChar](repeating: 0, count: size)
    let valueResult = key.withCString { pointer in
        sysctlbyname(pointer, &buffer, &size, nil, 0)
    }

    guard valueResult == 0 else { return nil }
    let utf8Bytes = buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
    return String(decoding: utf8Bytes, as: UTF8.self)
}

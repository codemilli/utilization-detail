import Darwin
import Foundation

final class LiveCPUTelemetryProvider {
    private let descriptorReader: SystemCPUDescriptorReader
    private var cachedDevice: CPUDeviceDescriptor?
    private var previousLoadInfo: [UInt32]?
    private var syntheticPhase = 0.0

    init(descriptorReader: SystemCPUDescriptorReader = .init()) {
        self.descriptorReader = descriptorReader
    }

    func sample(at timestamp: Date = .now) -> CPUCoreTelemetrySnapshot {
        let device = cachedDevice ?? descriptorReader.read()
        cachedDevice = device

        if let liveReadings = currentCPUUtilizations(), !liveReadings.isEmpty {
            return CPUCoreTelemetrySnapshot(
                timestamp: timestamp,
                device: device,
                utilizationsByCoreIndex: Dictionary(
                    uniqueKeysWithValues: liveReadings.enumerated().map { ($0.offset, $0.element) }
                ),
                isLive: true
            )
        }

        syntheticPhase += 0.32
        let fallbackValues = device.cores.map { descriptor in
            (descriptor.cpuIndex, syntheticUtilization(for: descriptor, phase: syntheticPhase))
        }

        return CPUCoreTelemetrySnapshot(
            timestamp: timestamp,
            device: device,
            utilizationsByCoreIndex: Dictionary(uniqueKeysWithValues: fallbackValues),
            isLive: false
        )
    }

    private func currentCPUUtilizations() -> [Double]? {
        var processorInfo: processor_info_array_t?
        var processorInfoCount: mach_msg_type_number_t = 0
        var coreCount: natural_t = 0

        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &coreCount,
            &processorInfo,
            &processorInfoCount
        )

        guard result == KERN_SUCCESS, let processorInfo else {
            return nil
        }

        let infoCount = Int(processorInfoCount)
        let buffer = Array(UnsafeBufferPointer(start: processorInfo, count: infoCount))

        defer {
            let byteCount = vm_size_t(infoCount * MemoryLayout<integer_t>.stride)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: processorInfo), byteCount)
        }

        let stride = Int(CPU_STATE_MAX)
        let currentTicks = buffer.map(UInt32.init)

        guard let previousLoadInfo, previousLoadInfo.count == currentTicks.count else {
            self.previousLoadInfo = currentTicks
            return nil
        }

        var utilizations: [Double] = []
        utilizations.reserveCapacity(Int(coreCount))

        for cpuIndex in 0..<Int(coreCount) {
            let offset = cpuIndex * stride
            let currentUser = currentTicks[offset + Int(CPU_STATE_USER)]
            let currentSystem = currentTicks[offset + Int(CPU_STATE_SYSTEM)]
            let currentIdle = currentTicks[offset + Int(CPU_STATE_IDLE)]
            let currentNice = currentTicks[offset + Int(CPU_STATE_NICE)]

            let previousUser = previousLoadInfo[offset + Int(CPU_STATE_USER)]
            let previousSystem = previousLoadInfo[offset + Int(CPU_STATE_SYSTEM)]
            let previousIdle = previousLoadInfo[offset + Int(CPU_STATE_IDLE)]
            let previousNice = previousLoadInfo[offset + Int(CPU_STATE_NICE)]

            let deltaUser = currentUser &- previousUser
            let deltaSystem = currentSystem &- previousSystem
            let deltaIdle = currentIdle &- previousIdle
            let deltaNice = currentNice &- previousNice
            let deltaTotal = deltaUser + deltaSystem + deltaIdle + deltaNice

            let utilization: Double
            if deltaTotal == 0 {
                utilization = 0
            } else {
                utilization = Double(deltaUser + deltaSystem + deltaNice) / Double(deltaTotal) * 100
            }

            utilizations.append(utilization)
        }

        self.previousLoadInfo = currentTicks
        return utilizations
    }

    private func syntheticUtilization(for descriptor: CPUCoreDescriptor, phase: Double) -> Double {
        let cpuBias = Double(descriptor.cpuIndex) * 0.47
        let primaryWave = (sin(phase + cpuBias) + 1) * 0.5
        let secondaryWave = (sin((phase * 1.9) + cpuBias * 1.3) + 1) * 0.5
        let spikeGate = max(0, sin((phase * 4.4) - Double(descriptor.ordinal) * 0.35))

        let baseFloor: Double
        let amplitude: Double
        let spikeScale: Double

        switch descriptor.kind {
        case .superCore:
            baseFloor = 12
            amplitude = 28
            spikeScale = 44
        case .efficiency:
            baseFloor = 3
            amplitude = 12
            spikeScale = 24
        case .performance:
            baseFloor = 8
            amplitude = 22
            spikeScale = 38
        }

        let utilization = baseFloor + (primaryWave * amplitude) + (secondaryWave * 7) + (spikeGate * spikeScale)
        return min(utilization, 100)
    }
}

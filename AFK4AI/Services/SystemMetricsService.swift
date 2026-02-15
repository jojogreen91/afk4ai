import Foundation
import IOKit

class SystemMetricsService {
    private var timer: Timer?
    private var onUpdate: ((SystemMetrics) -> Void)?

    // CPU delta tracking
    private var previousCPUInfo: processor_info_array_t?
    private var previousCPUInfoCount: mach_msg_type_number_t = 0

    // Network delta tracking
    private var previousNetBytesIn: UInt64 = 0
    private var previousNetBytesOut: UInt64 = 0
    private var previousNetTimestamp: Date?

    func startMonitoring(onUpdate: @escaping (SystemMetrics) -> Void) {
        self.onUpdate = onUpdate
        pollMetrics()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.pollMetrics()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        onUpdate = nil
        deallocatePreviousCPUInfo()
    }

    deinit {
        stopMonitoring()
    }

    private func pollMetrics() {
        var metrics = SystemMetrics()
        metrics.cpuUsage = readCPUUsage()
        let (used, total) = readMemoryUsage()
        metrics.memoryUsed = used
        metrics.memoryTotal = total
        let (gpuPct, gpuOk) = readGPUUsage()
        metrics.gpuUsage = gpuPct
        metrics.gpuAvailable = gpuOk
        let (upSpeed, downSpeed) = readNetworkSpeed()
        metrics.networkUpSpeed = upSpeed
        metrics.networkDownSpeed = downSpeed
        DispatchQueue.main.async { [weak self] in
            self?.onUpdate?(metrics)
        }
    }

    // MARK: - CPU (Mach host_processor_info)

    private func readCPUUsage() -> Double {
        var numCPUs: natural_t = 0
        var cpuInfo: processor_info_array_t?
        var cpuInfoCount: mach_msg_type_number_t = 0

        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCPUs,
            &cpuInfo,
            &cpuInfoCount
        )

        guard result == KERN_SUCCESS, let cpuInfo = cpuInfo else {
            return 0
        }

        var totalUsage: Double = 0

        if let previous = previousCPUInfo {
            for i in 0..<Int(numCPUs) {
                let offset = Int(CPU_STATE_MAX) * i
                let userDelta = Int64(cpuInfo[offset + Int(CPU_STATE_USER)]) - Int64(previous[offset + Int(CPU_STATE_USER)])
                let systemDelta = Int64(cpuInfo[offset + Int(CPU_STATE_SYSTEM)]) - Int64(previous[offset + Int(CPU_STATE_SYSTEM)])
                let niceDelta = Int64(cpuInfo[offset + Int(CPU_STATE_NICE)]) - Int64(previous[offset + Int(CPU_STATE_NICE)])
                let idleDelta = Int64(cpuInfo[offset + Int(CPU_STATE_IDLE)]) - Int64(previous[offset + Int(CPU_STATE_IDLE)])

                let totalTicks = userDelta + systemDelta + niceDelta + idleDelta
                if totalTicks > 0 {
                    let usedTicks = userDelta + systemDelta + niceDelta
                    totalUsage += Double(usedTicks) / Double(totalTicks)
                }
            }
            totalUsage = (totalUsage / Double(numCPUs)) * 100.0
        }

        deallocatePreviousCPUInfo()
        previousCPUInfo = cpuInfo
        previousCPUInfoCount = cpuInfoCount

        return min(totalUsage, 100.0)
    }

    private func deallocatePreviousCPUInfo() {
        if let prev = previousCPUInfo {
            let prevSize = vm_size_t(previousCPUInfoCount) * vm_size_t(MemoryLayout<integer_t>.stride)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prev), prevSize)
            previousCPUInfo = nil
            previousCPUInfoCount = 0
        }
    }

    // MARK: - Memory (Mach host_statistics64)

    private func readMemoryUsage() -> (used: UInt64, total: UInt64) {
        let total = ProcessInfo.processInfo.physicalMemory

        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.stride / MemoryLayout<integer_t>.stride)

        let result = withUnsafeMutablePointer(to: &vmStats) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, intPtr, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return (0, total)
        }

        let pageSize = UInt64(vm_kernel_page_size)
        let active = UInt64(vmStats.active_count) * pageSize
        let wired = UInt64(vmStats.wire_count) * pageSize
        let compressed = UInt64(vmStats.compressor_page_count) * pageSize
        let used = active + wired + compressed

        return (used, total)
    }

    // MARK: - GPU (IOKit IOAccelerator)

    private func readGPUUsage() -> (percentage: Double, available: Bool) {
        let matching = IOServiceMatching("IOAccelerator")
        var iterator: io_iterator_t = 0

        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else {
            return (0, false)
        }
        defer { IOObjectRelease(iterator) }

        var entry = IOIteratorNext(iterator)
        while entry != 0 {
            defer { IOObjectRelease(entry) }

            var properties: Unmanaged<CFMutableDictionary>?
            guard IORegistryEntryCreateCFProperties(entry, &properties, kCFAllocatorDefault, 0) == KERN_SUCCESS,
                  let props = properties?.takeRetainedValue() as? [String: Any],
                  let perfStats = props["PerformanceStatistics"] as? [String: Any] else {
                entry = IOIteratorNext(iterator)
                continue
            }

            // Try known GPU utilization keys
            let keys = ["GPU Activity(%)", "Device Utilization %", "GPU Core Utilization %"]
            for key in keys {
                if let value = perfStats[key] as? Int {
                    return (Double(min(value, 100)), true)
                }
                if let value = perfStats[key] as? Double {
                    return (min(value, 100), true)
                }
            }

            entry = IOIteratorNext(iterator)
        }

        return (0, false)
    }

    // MARK: - Network (getifaddrs)

    private func readNetworkSpeed() -> (upBytesPerSec: Double, downBytesPerSec: Double) {
        var totalIn: UInt64 = 0
        var totalOut: UInt64 = 0

        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return (0, 0)
        }
        defer { freeifaddrs(ifaddr) }

        var cursor: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let addr = cursor {
            let name = String(cString: addr.pointee.ifa_name)
            // Skip loopback
            if name != "lo0" && addr.pointee.ifa_addr.pointee.sa_family == UInt8(AF_LINK) {
                let data = unsafeBitCast(addr.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
                totalIn += UInt64(data.pointee.ifi_ibytes)
                totalOut += UInt64(data.pointee.ifi_obytes)
            }
            cursor = addr.pointee.ifa_next
        }

        let now = Date()
        var upSpeed: Double = 0
        var downSpeed: Double = 0

        if let prevTime = previousNetTimestamp {
            let elapsed = now.timeIntervalSince(prevTime)
            if elapsed > 0 {
                // Handle counter wraparound
                let deltaIn = totalIn >= previousNetBytesIn ? totalIn - previousNetBytesIn : totalIn
                let deltaOut = totalOut >= previousNetBytesOut ? totalOut - previousNetBytesOut : totalOut
                downSpeed = Double(deltaIn) / elapsed
                upSpeed = Double(deltaOut) / elapsed
            }
        }

        previousNetBytesIn = totalIn
        previousNetBytesOut = totalOut
        previousNetTimestamp = now

        return (upSpeed, downSpeed)
    }
}

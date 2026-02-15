import Foundation

struct SystemMetrics {
    var cpuUsage: Double = 0        // 0.0 - 100.0
    var memoryUsed: UInt64 = 0      // bytes
    var memoryTotal: UInt64 = 0     // bytes
    var gpuUsage: Double = 0        // 0.0 - 100.0
    var gpuAvailable: Bool = false
    var networkUpSpeed: Double = 0   // bytes per second
    var networkDownSpeed: Double = 0 // bytes per second

    var cpuPercent: String {
        String(format: "%.0f%%", cpuUsage)
    }

    var memoryPercent: Double {
        guard memoryTotal > 0 else { return 0 }
        return Double(memoryUsed) / Double(memoryTotal) * 100
    }

    var memoryDisplay: String {
        let usedGB = Double(memoryUsed) / 1_073_741_824
        let totalGB = Double(memoryTotal) / 1_073_741_824
        return String(format: "%.1f/%.0fGB", usedGB, totalGB)
    }

    var gpuPercent: String {
        String(format: "%.0f%%", gpuUsage)
    }

    static func formatSpeed(_ bytesPerSec: Double) -> String {
        if bytesPerSec < 1024 {
            return String(format: "%.0f B/s", bytesPerSec)
        } else if bytesPerSec < 1_048_576 {
            return String(format: "%.1f KB/s", bytesPerSec / 1024)
        } else {
            return String(format: "%.1f MB/s", bytesPerSec / 1_048_576)
        }
    }
}

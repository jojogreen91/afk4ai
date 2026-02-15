import SwiftUI

struct MetricsBarView: View {
    let metrics: SystemMetrics
    var primary: Color
    var elapsedTime: String?

    var body: some View {
        HStack(spacing: 0) {
            // Elapsed time (leftmost)
            if let elapsed = elapsedTime {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(primary)

                    Text(elapsed)
                        .font(Theme.mono(20, weight: .bold))
                        .foregroundColor(primary)
                        .monospacedDigit()
                }

                metricDivider
            }

            MetricGaugeView(
                icon: "cpu",
                label: "CPU",
                value: metrics.cpuUsage,
                displayText: metrics.cpuPercent,
                color: primary
            )

            metricDivider

            MetricGaugeView(
                icon: "memorychip",
                label: "MEM",
                value: metrics.memoryPercent,
                displayText: metrics.memoryDisplay,
                color: primary
            )

            if metrics.gpuAvailable {
                metricDivider

                MetricGaugeView(
                    icon: "gpu",
                    label: "GPU",
                    value: metrics.gpuUsage,
                    displayText: metrics.gpuPercent,
                    color: primary
                )
            }

            metricDivider

            NetworkMetricView(
                upSpeed: metrics.networkUpSpeed,
                downSpeed: metrics.networkDownSpeed,
                color: primary
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.6))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(primary.opacity(0.3)),
            alignment: .top
        )
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(primary.opacity(0.3)),
            alignment: .bottom
        )
    }

    private var metricDivider: some View {
        Rectangle()
            .fill(primary.opacity(0.2))
            .frame(width: 1, height: 32)
            .padding(.horizontal, 18)
    }
}

// MARK: - Individual Metric Gauge

private struct MetricGaugeView: View {
    let icon: String
    let label: String
    let value: Double       // 0-100
    let displayText: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color.opacity(0.9))

            Text(label)
                .font(Theme.mono(14, weight: .bold))
                .foregroundColor(color.opacity(0.8))

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.2))

                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.85))
                        .frame(width: geo.size.width * min(CGFloat(value) / 100.0, 1.0))
                }
            }
            .frame(width: 90, height: 7)

            Text(displayText)
                .font(Theme.mono(16, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
                .monospacedDigit()
                .frame(minWidth: 52, alignment: .trailing)
        }
    }
}

// MARK: - Network Metric

private struct NetworkMetricView: View {
    let upSpeed: Double
    let downSpeed: Double
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "network")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color.opacity(0.9))

            Text("NET")
                .font(Theme.mono(14, weight: .bold))
                .foregroundColor(color.opacity(0.8))

            HStack(spacing: 5) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(color.opacity(0.8))
                Text(SystemMetrics.formatSpeed(upSpeed))
                    .font(Theme.mono(14, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .monospacedDigit()
                    .frame(minWidth: 70, alignment: .trailing)
            }

            HStack(spacing: 5) {
                Image(systemName: "arrow.down")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(color.opacity(0.8))
                Text(SystemMetrics.formatSpeed(downSpeed))
                    .font(Theme.mono(14, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .monospacedDigit()
                    .frame(minWidth: 70, alignment: .trailing)
            }
        }
    }
}

import SwiftUI

struct MetricsBarView: View {
    let metrics: SystemMetrics
    var primary: Color

    var body: some View {
        HStack(spacing: 0) {
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
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.5))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(primary.opacity(0.2)),
            alignment: .top
        )
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(primary.opacity(0.2)),
            alignment: .bottom
        )
    }

    private var metricDivider: some View {
        Rectangle()
            .fill(primary.opacity(0.15))
            .frame(width: 1, height: 30)
            .padding(.horizontal, 16)
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
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color.opacity(0.7))

            Text(label)
                .font(Theme.mono(13, weight: .bold))
                .foregroundColor(color.opacity(0.6))

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(color.opacity(0.15))

                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(color.opacity(0.7))
                        .frame(width: geo.size.width * min(CGFloat(value) / 100.0, 1.0))
                }
            }
            .frame(width: 80, height: 5)

            Text(displayText)
                .font(Theme.mono(15, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Network Metric

private struct NetworkMetricView: View {
    let upSpeed: Double
    let downSpeed: Double
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "network")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color.opacity(0.7))

            Text("NET")
                .font(Theme.mono(13, weight: .bold))
                .foregroundColor(color.opacity(0.6))

            HStack(spacing: 5) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color.opacity(0.6))
                Text(SystemMetrics.formatSpeed(upSpeed))
                    .font(Theme.mono(13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }

            HStack(spacing: 5) {
                Image(systemName: "arrow.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color.opacity(0.6))
                Text(SystemMetrics.formatSpeed(downSpeed))
                    .font(Theme.mono(13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

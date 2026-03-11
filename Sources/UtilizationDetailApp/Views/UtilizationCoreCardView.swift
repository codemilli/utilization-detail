import SwiftUI

struct UtilizationCoreCardView: View {
    let metric: CPUCoreMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(UtilizationDashboardStyle.tint(for: metric.kind))
                        .frame(width: 7, height: 7)

                    Text(metric.id)
                        .font(.headline.monospaced())
                }

                Spacer(minLength: 0)

                Text(metric.currentUtilization.formatted(.number.precision(.fractionLength(2))) + "%")
                    .font(.title3.monospacedDigit())
                    .bold()
            }

            UtilizationSparklineView(
                samples: metric.samples,
                tint: UtilizationDashboardStyle.tint(for: metric.kind)
            )

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("LATEST")
                        .font(.caption)
                        .foregroundStyle(UtilizationDashboardStyle.labelColor)

                    Text(metric.latestTimestamp, format: .dateTime.hour().minute().second())
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("PEAK")
                        .font(.caption)
                        .foregroundStyle(UtilizationDashboardStyle.labelColor)

                    Text(metric.peakUtilization.formatted(.number.precision(.fractionLength(2))) + "%")
                        .font(.caption.monospacedDigit())
                        .bold()
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 190, alignment: .topLeading)
        .background(UtilizationDashboardStyle.cardFill(for: metric.kind))
        .background(UtilizationDashboardStyle.panelBackground)
        .clipShape(.rect(cornerRadius: UtilizationDashboardStyle.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: UtilizationDashboardStyle.cardCornerRadius)
                .stroke(UtilizationDashboardStyle.tint(for: metric.kind).opacity(0.28), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(metric.id) \(metric.kind.accessibilityLabel) core")
        .accessibilityValue(
            "Current \(metric.currentUtilization.formatted(.number.precision(.fractionLength(2)))) percent, peak \(metric.peakUtilization.formatted(.number.precision(.fractionLength(2)))) percent"
        )
    }
}

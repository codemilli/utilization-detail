import SwiftUI

struct UtilizationClusterCardView: View {
    let metric: CPUClusterMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(metric.kind.sectionTitle)
                        .font(.title3.monospaced())
                        .bold()

                    Text("\(metric.coreCount) cores")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Text(metric.currentUtilization.formatted(.number.precision(.fractionLength(2))) + "%")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .monospacedDigit()
            }

            UtilizationSparklineView(
                samples: metric.samples,
                tint: UtilizationDashboardStyle.tint(for: metric.kind)
            )
            .frame(minHeight: UtilizationDashboardStyle.headerChartHeight, maxHeight: UtilizationDashboardStyle.headerChartHeight)

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
                        .font(.headline.monospacedDigit())
                        .bold()
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 248, alignment: .topLeading)
        .background(UtilizationDashboardStyle.cardFill(for: metric.kind))
        .background(UtilizationDashboardStyle.panelBackground)
        .clipShape(.rect(cornerRadius: UtilizationDashboardStyle.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: UtilizationDashboardStyle.cardCornerRadius)
                .stroke(UtilizationDashboardStyle.tint(for: metric.kind).opacity(0.28), lineWidth: 1)
        }
    }
}

import SwiftUI

struct UtilizationHeaderView: View {
    let deviceName: String
    let chartSummary: String
    let lastUpdated: Date?
    let isLiveTelemetry: Bool
    let displayModeSubtitle: String
    @Binding var displayMode: UtilizationDisplayMode

    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Utilization Detail")
                    .font(.largeTitle)
                    .bold()

                Text(deviceName)
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text(chartSummary)
                    .font(.headline.monospaced())
                    .foregroundStyle(.primary)
                    .padding(.top, 4)

                HStack(spacing: 10) {
                    Circle()
                        .fill(isLiveTelemetry ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)

                    Text(isLiveTelemetry ? "Live telemetry" : "Preview telemetry")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let lastUpdated {
                        Text(lastUpdated, format: .dateTime.hour().minute().second())
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Text("Display\nmode")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.primary)

                    UtilizationModePickerView(displayMode: $displayMode)
                }

                Text(displayModeSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Hover any chart for exact utilization.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

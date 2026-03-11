import SwiftUI

struct UtilizationSectionView: View {
    let kind: CPUCoreKind
    let metrics: [CPUCoreMetric]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text(kind.sectionTitle)
                    .font(.headline.monospaced())

                Text("\(metrics.count)")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            UtilizationCoreGridView(metrics: metrics)
        }
    }
}

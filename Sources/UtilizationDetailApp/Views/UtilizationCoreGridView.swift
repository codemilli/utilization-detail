import SwiftUI

struct UtilizationCoreGridView: View {
    let metrics: [CPUCoreMetric]

    private let columns = [
        GridItem(
            .adaptive(
                minimum: UtilizationDashboardStyle.cardMinimumWidth,
                maximum: UtilizationDashboardStyle.cardMaximumWidth
            ),
            spacing: UtilizationDashboardStyle.cardSpacing,
            alignment: .top
        )
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: UtilizationDashboardStyle.cardSpacing) {
            ForEach(metrics) { metric in
                UtilizationCoreCardView(metric: metric)
            }
        }
    }
}

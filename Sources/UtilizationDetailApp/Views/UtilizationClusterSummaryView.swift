import SwiftUI

struct UtilizationClusterSummaryView: View {
    let metrics: [CPUClusterMetric]

    private let columns = [
        GridItem(
            .adaptive(
                minimum: UtilizationDashboardStyle.clusterMinimumWidth,
                maximum: UtilizationDashboardStyle.clusterMaximumWidth
            ),
            spacing: UtilizationDashboardStyle.cardSpacing,
            alignment: .top
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("CLUSTERS")
                .font(.headline.monospaced())

            LazyVGrid(columns: columns, alignment: .leading, spacing: UtilizationDashboardStyle.cardSpacing) {
                ForEach(metrics) { metric in
                    UtilizationClusterCardView(metric: metric)
                }
            }
        }
    }
}

import SwiftUI

struct UtilizationDashboardView: View {
    @Bindable var model: UtilizationDashboardModel

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.09)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: UtilizationDashboardStyle.sectionSpacing) {
                    UtilizationHeaderView(
                        deviceName: model.deviceName,
                        chartSummary: model.chartSummary,
                        lastUpdated: model.lastUpdated,
                        isLiveTelemetry: model.isLiveTelemetry,
                        displayModeSubtitle: model.displayMode.subtitle,
                        displayMode: $model.displayMode
                    )

                    if model.displayMode == .cluster {
                        UtilizationClusterSummaryView(metrics: model.clusterMetrics)
                    } else {
                        ForEach(model.activeKinds, id: \.self) { kind in
                            UtilizationSectionView(kind: kind, metrics: model.metrics(for: kind))
                        }
                    }

                    UtilizationFooterView(footnote: model.telemetryFootnote)
                }
                .foregroundStyle(.white)
                .padding(UtilizationDashboardStyle.pagePadding)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .scrollContentBackground(.visible)
        }
        .task {
            model.startSampling()
        }
        .onDisappear {
            model.stopSampling()
        }
    }
}

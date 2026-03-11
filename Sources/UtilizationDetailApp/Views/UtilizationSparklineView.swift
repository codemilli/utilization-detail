import SwiftUI

struct UtilizationSparklineView: View {
    let samples: [Double]
    let tint: Color

    @State private var hoveredIndex: Int?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.clear)

                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height - 1))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height - 1))
                }
                .stroke(tint.opacity(0.28), lineWidth: 1)

                UtilizationSparklineShape.path(for: samples, in: geometry.size)
                    .stroke(tint, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                if let hoveredIndex,
                   let point = UtilizationSparklineShape.point(at: hoveredIndex, in: samples, size: geometry.size) {
                    Path { path in
                        path.move(to: CGPoint(x: point.x, y: 0))
                        path.addLine(to: CGPoint(x: point.x, y: geometry.size.height))
                    }
                    .stroke(tint.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))

                    Circle()
                        .fill(tint)
                        .frame(width: 8, height: 8)
                        .position(point)
                }

                if let hoveredIndex, samples.indices.contains(hoveredIndex) {
                    Text(samples[hoveredIndex].formatted(.number.precision(.fractionLength(2))) + "%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.regularMaterial)
                        .clipShape(.rect(cornerRadius: 8))
                        .padding(8)
                }
            }
            .contentShape(.rect)
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    hoveredIndex = index(for: location.x, width: geometry.size.width)
                case .ended:
                    hoveredIndex = nil
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: UtilizationDashboardStyle.chartHeight, maxHeight: UtilizationDashboardStyle.chartHeight)
        .accessibilityLabel("Utilization chart")
        .accessibilityValue(currentValueText)
    }

    private var currentValueText: String {
        let value = hoveredIndex.flatMap { index in
            samples.indices.contains(index) ? samples[index] : nil
        } ?? samples.last ?? 0
        return value.formatted(.number.precision(.fractionLength(2))) + " percent"
    }

    private func index(for xPosition: CGFloat, width: CGFloat) -> Int? {
        guard width > 0, !samples.isEmpty else { return nil }
        let progress = min(max(xPosition / width, 0), 1)
        let rawIndex = Int(round(progress * CGFloat(max(samples.count - 1, 0))))
        return samples.indices.contains(rawIndex) ? rawIndex : nil
    }
}

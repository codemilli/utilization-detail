import SwiftUI

struct UtilizationSparklineShape {
    static func path(for samples: [Double], in size: CGSize) -> Path {
        var path = Path()

        guard let firstPoint = point(at: 0, in: samples, size: size) else {
            return path
        }

        path.move(to: firstPoint)

        for index in 1..<samples.count {
            guard let point = point(at: index, in: samples, size: size) else { continue }
            path.addLine(to: point)
        }

        return path
    }

    static func point(at index: Int, in samples: [Double], size: CGSize) -> CGPoint? {
        guard samples.indices.contains(index), size.width > 0, size.height > 0 else {
            return nil
        }

        let denominator = max(samples.count - 1, 1)
        let x = size.width * CGFloat(index) / CGFloat(denominator)
        let normalized = min(max(samples[index] / 100, 0), 1)
        let y = size.height - (size.height * CGFloat(normalized))
        return CGPoint(x: x, y: y)
    }
}

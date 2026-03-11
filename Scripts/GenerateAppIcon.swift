import AppKit
import Foundation

let projectRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let resourcesDirectory = projectRoot.appending(path: "Sources/UtilizationDetailApp/Resources")
let appIconSetDirectory = resourcesDirectory.appending(path: "AppIcon.appiconset")
let buildDirectory = projectRoot.appending(path: "Build")
let iconSetDirectory = buildDirectory.appending(path: "AppIcon.iconset")
let icnsFile = buildDirectory.appending(path: "AppIcon.icns")

let iconDefinitions: [(size: Int, name: String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

try FileManager.default.createDirectory(at: appIconSetDirectory, withIntermediateDirectories: true)
try FileManager.default.createDirectory(at: iconSetDirectory, withIntermediateDirectories: true)
try FileManager.default.createDirectory(at: buildDirectory, withIntermediateDirectories: true)

for definition in iconDefinitions {
    let pngData = try renderIcon(size: definition.size)
    try pngData.write(to: appIconSetDirectory.appending(path: definition.name))
    try pngData.write(to: iconSetDirectory.appending(path: definition.name))
}

let masterPNG = try renderIcon(size: 1024)
try masterPNG.write(to: resourcesDirectory.appending(path: "AppIcon-1024.png"))
try masterPNG.write(to: buildDirectory.appending(path: "AppIcon-1024.png"))

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconSetDirectory.path(), "-o", icnsFile.path()]
try process.run()
process.waitUntilExit()

guard process.terminationStatus == 0 else {
    throw NSError(domain: "GenerateAppIcon", code: Int(process.terminationStatus))
}

print("Generated icon assets at \(appIconSetDirectory.path()) and \(icnsFile.path())")

func renderIcon(size: Int) throws -> Data {
    let imageSize = NSSize(width: size, height: size)
    guard
        let representation = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: size,
            pixelsHigh: size,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )
    else {
        throw NSError(domain: "GenerateAppIcon", code: 1)
    }

    representation.size = imageSize

    guard let context = NSGraphicsContext(bitmapImageRep: representation) else {
        throw NSError(domain: "GenerateAppIcon", code: 2)
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context

    let canvas = NSRect(origin: .zero, size: imageSize)
    drawBackground(in: canvas)
    drawChip(in: canvas)
    drawWave(in: canvas)
    drawEdge(in: canvas)

    NSGraphicsContext.restoreGraphicsState()

    guard let data = representation.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "GenerateAppIcon", code: 3)
    }

    return data
}

func drawBackground(in rect: NSRect) {
    let basePath = NSBezierPath(
        roundedRect: rect.insetBy(dx: rect.width * 0.02, dy: rect.height * 0.02),
        xRadius: rect.width * 0.23,
        yRadius: rect.height * 0.23
    )

    basePath.addClip()

    let graphite = NSGradient(colors: [
        NSColor(calibratedRed: 0.39, green: 0.42, blue: 0.46, alpha: 1),
        NSColor(calibratedRed: 0.17, green: 0.19, blue: 0.22, alpha: 1),
    ])!
    graphite.draw(in: basePath, angle: -45)

    let topHighlight = NSGradient(colors: [
        NSColor(calibratedWhite: 1, alpha: 0.24),
        NSColor(calibratedWhite: 1, alpha: 0.02),
    ])!
    let topRect = NSRect(
        x: rect.width * 0.08,
        y: rect.height * 0.55,
        width: rect.width * 0.64,
        height: rect.height * 0.36
    )
    topHighlight.draw(in: NSBezierPath(ovalIn: topRect), relativeCenterPosition: .zero)

    let blueGlow = NSGradient(colors: [
        NSColor(calibratedRed: 0.27, green: 0.61, blue: 1, alpha: 0.25),
        NSColor(calibratedRed: 0.27, green: 0.61, blue: 1, alpha: 0.0),
    ])!
    let glowRect = NSRect(
        x: rect.width * 0.34,
        y: rect.height * 0.02,
        width: rect.width * 0.58,
        height: rect.height * 0.42
    )
    blueGlow.draw(in: NSBezierPath(ovalIn: glowRect), relativeCenterPosition: .zero)
}

func drawChip(in rect: NSRect) {
    let chipRect = rect.insetBy(dx: rect.width * 0.22, dy: rect.height * 0.22)
    let chipPath = NSBezierPath(
        roundedRect: chipRect,
        xRadius: rect.width * 0.12,
        yRadius: rect.height * 0.12
    )

    NSColor(calibratedWhite: 1, alpha: 0.065).setFill()
    chipPath.fill()

    NSColor(calibratedWhite: 1, alpha: 0.18).setStroke()
    chipPath.lineWidth = rect.width * 0.018
    chipPath.stroke()

    let notchFill = NSColor(calibratedWhite: 1, alpha: 0.16)
    let notchWidth = rect.width * 0.028
    let notchHeight = rect.height * 0.07
    let positions: [CGFloat] = [0.34, 0.46, 0.58]

    for xFactor in positions {
        let notch = NSBezierPath(
            roundedRect: NSRect(
                x: rect.width * xFactor,
                y: chipRect.maxY - rect.height * 0.02,
                width: notchWidth,
                height: notchHeight
            ),
            xRadius: notchWidth * 0.45,
            yRadius: notchWidth * 0.45
        )
        notchFill.setFill()
        notch.fill()
    }
}

func drawWave(in rect: NSRect) {
    let wave = NSBezierPath()
    wave.lineWidth = rect.width * 0.03
    wave.lineJoinStyle = .round
    wave.lineCapStyle = .round

    let points = [
        CGPoint(x: 0.26, y: 0.44),
        CGPoint(x: 0.38, y: 0.44),
        CGPoint(x: 0.46, y: 0.44),
        CGPoint(x: 0.52, y: 0.61),
        CGPoint(x: 0.57, y: 0.35),
        CGPoint(x: 0.63, y: 0.56),
        CGPoint(x: 0.71, y: 0.43),
        CGPoint(x: 0.79, y: 0.50),
    ]

    for (index, point) in points.enumerated() {
        let scaledPoint = CGPoint(x: rect.width * point.x, y: rect.height * point.y)
        if index == 0 {
            wave.move(to: scaledPoint)
        } else {
            wave.line(to: scaledPoint)
        }
    }

    NSColor(calibratedRed: 0.27, green: 0.61, blue: 1.0, alpha: 1).setStroke()
    wave.stroke()
}

func drawEdge(in rect: NSRect) {
    let edgePath = NSBezierPath(
        roundedRect: rect.insetBy(dx: rect.width * 0.02, dy: rect.height * 0.02),
        xRadius: rect.width * 0.23,
        yRadius: rect.height * 0.23
    )

    NSColor(calibratedWhite: 1, alpha: 0.16).setStroke()
    edgePath.lineWidth = rect.width * 0.01
    edgePath.stroke()
}

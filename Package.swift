// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "UtilizationDetail",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "UtilizationDetailApp",
            targets: ["UtilizationDetailApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "UtilizationDetailApp",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "UtilizationDetailAppTests",
            dependencies: ["UtilizationDetailApp"]
        )
    ]
)

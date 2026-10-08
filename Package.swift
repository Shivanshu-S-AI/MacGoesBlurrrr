// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GlassScreen",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "GlassScreen",
            targets: ["GlassScreen"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "GlassScreen",
            dependencies: [],
            path: "Sources/GlassScreen"
        )
    ]
)

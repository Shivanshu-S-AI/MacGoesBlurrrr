// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MacGoesBlurrrr",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MacGoesBlurrrr",
            targets: ["MacGoesBlurrrr"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MacGoesBlurrrr",
            dependencies: [],
            path: "Sources/MacGoesBlurrrr"
        )
    ]
)

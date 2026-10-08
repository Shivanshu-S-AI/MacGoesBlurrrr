// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MacMyBusiness",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MacMyBusiness",
            targets: ["MacMyBusiness"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MacMyBusiness",
            dependencies: [],
            path: "Sources/MacMyBusiness"
        )
    ]
)

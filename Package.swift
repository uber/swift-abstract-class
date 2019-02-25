// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "AbstractClassFoundation",
    products: [
        .library(name: "AbstractClassFoundation", targets: ["AbstractClassFoundation"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AbstractClassFoundation",
            dependencies: []),
        .testTarget(
            name: "AbstractClassFoundationTests",
            dependencies: ["AbstractClassFoundation"],
            exclude: []),
    ],
    swiftLanguageVersions: [4]
)

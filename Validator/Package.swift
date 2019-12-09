// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "AbstractClassValidator",
    products: [
        .executable(name: "abstractclassvalidator", targets: ["abstractclassvalidator"]),
        .library(name: "AbstractClassValidatorFramework", targets: ["AbstractClassValidatorFramework"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.20.0"),
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0"),
        .package(url: "https://github.com/uber/swift-concurrency.git", .upToNextMajor(from: "0.7.1")),
        .package(url: "https://github.com/uber/swift-common.git", .exact("0.1.0")),
    ],
    targets: [
        .target(
            name: "abstractclassvalidator",
            dependencies: [
                "CommandFramework",
                "AbstractClassValidatorFramework",
            ]),
        .target(
            name: "AbstractClassValidatorFramework",
            dependencies: [
                "Utility",
                "SourceKittenFramework",
                "Concurrency",
                "SourceParsingFramework",
            ]),
        .testTarget(
            name: "AbstractClassValidatorFrameworkTests",
            dependencies: ["AbstractClassValidatorFramework"],
            exclude: [
                "Fixtures",
            ]),
    ],
    swiftLanguageVersions: [4]
)

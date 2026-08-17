// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Validator",
    platforms: [
        // Raised to match skip-fuse-ui, which requires iOS 17 / macOS 14 / tvOS 17 / watchOS 10.
        // A lower floor here makes SwiftPM reject the dependency during resolution.
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "ValidatorCore", type: .dynamic, targets: ["ValidatorCore"]),
        .library(name: "ValidatorUI", type: .dynamic, targets: ["ValidatorUI"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.9.4"),
        .package(url: "https://source.skip.tools/skip-fuse.git", from: "1.0.0"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ValidatorCore",
            dependencies: [.product(name: "SkipFuse", package: "skip-fuse")],
            plugins: [.plugin(name: "skipstone", package: "skip")]
        ),
        .target(
            name: "ValidatorUI",
            dependencies: [
                "ValidatorCore",
                .product(name: "SkipFuseUI", package: "skip-fuse-ui"),
            ],
            plugins: [.plugin(name: "skipstone", package: "skip")]
        ),
        .testTarget(name: "ValidatorCoreTests", dependencies: ["ValidatorCore"]),
        .testTarget(name: "ValidatorUITests", dependencies: ["ValidatorCore", "ValidatorUI"]),
    ]
)

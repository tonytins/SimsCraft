// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "TSOFilesCheck",
    // A tool, so it may require a newer macOS than the libraries (see AGENTS.md, rule 5).
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "tsofiles-check", targets: ["TSOFilesCheck"]),
    ],
    dependencies: [
        .package(path: "../TSOFiles"),
        .package(path: "../TSOContent"),
        .package(url: "https://github.com/apple/swift-configuration", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        .executableTarget(name: "TSOFilesCheck", dependencies: [
            .product(name: "TSOFiles", package: "TSOFiles"),
            .product(name: "TSOContent", package: "TSOContent"),
            .product(name: "TSOConfig", package: "TSOContent"),
            .product(name: "Configuration", package: "swift-configuration"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        .testTarget(name: "TSOFilesCheckTests", dependencies: [
            "TSOFilesCheck",
            .product(name: "TSOFiles", package: "TSOFiles"),
            .product(name: "TSOContent", package: "TSOContent"),
            .product(name: "Configuration", package: "swift-configuration"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
    ],
    swiftLanguageModes: [.v6]
)

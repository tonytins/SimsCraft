// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Client",
    // A tool, so it may require a newer macOS than the libraries: swift-configuration needs 15.
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "newso", targets: ["newso"]),
        .library(name: "LotScene", targets: ["LotScene"]),
    ],
    dependencies: [
        .package(path: "../TSOFiles"),
        .package(path: "../TSOContent"),
        .package(path: "../SimAntics"),
        .package(path: "../NSOInterface"),
        .package(url: "https://github.com/tonytins/raylib-swift", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.0"),
        .package(url: "https://github.com/apple/swift-configuration", from: "1.0.0"),
        // Headless and verbose runs log through it; it's already in the graph through swift-configuration.
        .package(url: "https://github.com/apple/swift-log", from: "1.16.0"),
    ],
    targets: [
        // What the client shows, worked out without raylib, so it's tested without a window.
        .target(name: "LotScene", dependencies: [
            .product(name: "SimAntics", package: "SimAntics"),
            .product(name: "TSOContent", package: "TSOContent"),
            .product(name: "TSOFiles", package: "TSOFiles"),
        ]),
        .executableTarget(name: "newso", dependencies: [
            "LotScene",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "Configuration", package: "swift-configuration"),
            .product(name: "NSOInterface", package: "NSOInterface"),
            .product(name: "Logging", package: "swift-log"),
            .product(name: "Raylib", package: "raylib-swift"),
            .product(name: "SimAntics", package: "SimAntics"),
            .product(name: "TSOConfig", package: "TSOContent"),
            .product(name: "TSOContent", package: "TSOContent"),
        ]),
        .testTarget(name: "LotSceneTests", dependencies: [
            "LotScene",
            .product(name: "SimAntics", package: "SimAntics"),
            .product(name: "TSOContent", package: "TSOContent"),
            .product(name: "TSOFiles", package: "TSOFiles"),
        ]),
    ],
    swiftLanguageModes: [.v6]
)

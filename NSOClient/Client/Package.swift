// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Client",
    products: [
        .executable(name: "newso", targets: ["newso"]),
        .library(name: "LotScene", targets: ["LotScene"]),
    ],
    dependencies: [
        .package(path: "../TSOFiles"),
        .package(path: "../TSOContent"),
        .package(path: "../SimAntics"),
        .package(path: "../Interface"),
        .package(url: "https://github.com/tonytins/raylib-swift", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.0"),
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
            .product(name: "Interface", package: "Interface"),
            .product(name: "Raylib", package: "raylib-swift"),
            .product(name: "SimAntics", package: "SimAntics"),
        ]),
        .testTarget(name: "LotSceneTests", dependencies: [
            "LotScene",
            .product(name: "SimAntics", package: "SimAntics"),
        ]),
    ],
    swiftLanguageModes: [.v6]
)

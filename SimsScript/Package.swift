// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SimsScript",
    products: [
        .library(name: "SimsScript", targets: ["SimsScript"]),
        .executable(name: "simsscript", targets: ["SimsScriptTool"]),
    ],
    dependencies: [
        .package(path: "../SimAntics"),
        .package(path: "../TSOContent"),
        .package(path: "../TSOFiles"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.0"),
    ],
    targets: [
        .target(name: "SimsScript", dependencies: [
            .product(name: "SimAntics", package: "SimAntics"),
            .product(name: "TSOContent", package: "TSOContent"),
            .product(name: "TSOFiles", package: "TSOFiles"),
        ]),
        // simsscript: reads an install's objects and prints their routines as SimsScript reads them.
        // Not named simsscript itself, which macOS's case-insensitive file system can't tell from SimsScript.
        .executableTarget(name: "SimsScriptTool", dependencies: [
            "SimsScript",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "TSOContent", package: "TSOContent"),
            .product(name: "TSOFiles", package: "TSOFiles"),
        ]),
        .testTarget(name: "SimsScriptTests", dependencies: [
            "SimsScript",
            .product(name: "SimAntics", package: "SimAntics"),
            .product(name: "TSOContent", package: "TSOContent"),
            .product(name: "TSOFiles", package: "TSOFiles"),
        ]),
    ],
    swiftLanguageModes: [.v6]
)

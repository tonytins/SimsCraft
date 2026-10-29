// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SimsScript",
    products: [
        .library(name: "SimsScript", targets: ["SimsScript"]),
        .executable(name: "simsscript", targets: ["simsscript"]),
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
        // Reads an install's objects and prints their routines as SimsScript reads them.
        .executableTarget(name: "simsscript", dependencies: [
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

// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "TSOContent",
    products: [
        .library(name: "TSOContent", targets: ["TSOContent"]),
        // The installs, read through swift-configuration, for the tools and the client.
        .library(name: "TSOConfig", targets: ["TSOConfig"]),
    ],
    dependencies: [
        .package(path: "../TSOFiles"),
        .package(url: "https://github.com/apple/swift-configuration", from: "1.0.0"),
    ],
    targets: [
        .target(name: "TSOContent", dependencies: ["TSOFiles"]),
        .target(name: "TSOConfig", dependencies: [
            "TSOContent",
            .product(name: "Configuration", package: "swift-configuration"),
        ]),
        .testTarget(name: "TSOContentTests", dependencies: ["TSOContent", "TSOFiles"]),
        .testTarget(name: "TSOConfigTests", dependencies: [
            "TSOConfig", "TSOContent",
            .product(name: "Configuration", package: "swift-configuration"),
        ]),
    ],
    swiftLanguageModes: [.v6]
)

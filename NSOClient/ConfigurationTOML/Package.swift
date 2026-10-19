// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ConfigurationTOML",
    products: [
        .library(name: "ConfigurationTOML", targets: ["ConfigurationTOML"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-configuration", from: "1.0.0"),
        .package(url: "https://github.com/mattt/swift-toml.git", from: "2.0.0"),
    ],
    targets: [
        .target(name: "ConfigurationTOML", dependencies: [
            .product(name: "Configuration", package: "swift-configuration"),
            .product(name: "TOML", package: "swift-toml"),
        ]),
    ],
    swiftLanguageModes: [.v6]
)

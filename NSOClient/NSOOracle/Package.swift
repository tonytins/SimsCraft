// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "NSOOracle",
    products: [
        .executable(name: "nso-oracle", targets: ["NSOOracle"]),
    ],
    dependencies: [
        .package(path: "../TSOFiles"),
        .package(path: "../ConfigurationTOML"),
        .package(path: "../TSOContent"),
        .package(path: "../SimAntics"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-configuration", from: "1.0.0"),
    ],
    targets: [
        .target(name: "NSOOracleCore", dependencies: [
            .product(name: "TSOFiles", package: "TSOFiles"),
            .product(name: "TSOContent", package: "TSOContent"),
            .product(name: "SimAntics", package: "SimAntics"),
        ]),
        .executableTarget(name: "NSOOracle", dependencies: [
            "NSOOracleCore",
            .product(name: "TSOContent", package: "TSOContent"),
            .product(name: "SimAntics", package: "SimAntics"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "Configuration", package: "swift-configuration"),
            .product(name: "ConfigurationTOML", package: "ConfigurationTOML"),
        ]),
        .testTarget(name: "NSOOracleTests", dependencies: [
            "NSOOracleCore",
            .product(name: "TSOContent", package: "TSOContent"),
            .product(name: "SimAntics", package: "SimAntics"),
        ]),
    ],
    swiftLanguageModes: [.v6]
)

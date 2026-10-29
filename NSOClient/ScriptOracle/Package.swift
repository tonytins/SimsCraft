// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ScriptOracle",
    products: [
        .executable(name: "sso-oracle", targets: ["ScriptOracle"]),
        .library(name: "ScriptOracleCore", targets: ["ScriptOracleCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.0"),
        .package(url: "https://github.com/apple/swift-configuration", from: "1.0.0"),
        .package(path: "../SimAntics"),
        .package(path: "../TSOContent"),
        .package(path: "../TSOFiles"),
        .package(url: "https://github.com/tonytins/SwiftConfigurationTOML", branch: "main"),
        .package(path: "../SimsScript"),
    ],
    targets: [
        .executableTarget(name: "ScriptOracle", dependencies: [
            "ScriptOracleCore",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "Configuration", package: "swift-configuration"),
            .product(name: "TSOConfig", package: "TSOContent"),
            .product(name: "ConfigurationTOML", package: "SwiftConfigurationTOML"),
        ]),
        .target(name: "ScriptOracleCore", dependencies: [
            .product(name: "SimAntics", package: "SimAntics"),
            .product(name: "SimsScript", package: "SimsScript"),
            .product(name: "TSOContent", package: "TSOContent"),
            .product(name: "TSOFiles", package: "TSOFiles"),
        ], resources: [
            .copy("Scenarios")
        ]),
        .testTarget(name: "ScriptOracleTests", dependencies: [
            "ScriptOracleCore",
        ]),
    ],
    swiftLanguageModes: [.v6]
)

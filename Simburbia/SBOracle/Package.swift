// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SBOracle",
    // A tool, so it may require a newer macOS than the libraries: swift-configuration needs 15.
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "sb-oracle", targets: ["SBOracle"]),
    ],
    dependencies: [
        .package(path: "../TSOFiles"),
        .package(url: "https://github.com/tonytins/SwiftConfigurationTOML", branch: "main"),
        .package(path: "../TSOContent"),
        .package(path: "../SimAntics"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-configuration", from: "1.0.0"),
    ],
    targets: [
        .target(name: "SBOracleCore", dependencies: [
            .product(name: "TSOFiles", package: "TSOFiles"),
            .product(name: "TSOContent", package: "TSOContent"),
            .product(name: "SimAntics", package: "SimAntics"),
        ]),
        .executableTarget(name: "SBOracle", dependencies: [
            "SBOracleCore",
            .product(name: "TSOContent", package: "TSOContent"),
            .product(name: "SimAntics", package: "SimAntics"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "Configuration", package: "swift-configuration"),
            .product(name: "TSOConfig", package: "TSOContent"),
            .product(name: "ConfigurationTOML", package: "SwiftConfigurationTOML"),
        ]),
        .testTarget(name: "SBOracleTests", dependencies: [
            "SBOracleCore",
            .product(name: "TSOContent", package: "TSOContent"),
            .product(name: "SimAntics", package: "SimAntics"),
        ]),
    ],
    swiftLanguageModes: [.v6]
)

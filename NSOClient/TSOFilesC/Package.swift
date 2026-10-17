// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "TSOFilesC",
    products: [
        .library(name: "TSOFilesC", targets: ["TSOFilesC"]),
    ],
    dependencies: [
        .package(path: "../TSOFiles"),
    ],
    targets: [
        .target(name: "TSOFilesCBridge", dependencies: ["TSOFiles"]),
        .target(name: "TSOFilesC", dependencies: ["TSOFilesCBridge"], publicHeadersPath: "include"),
        .testTarget(name: "TSOFilesCTests", dependencies: ["TSOFilesCBridge"]),
        .executableTarget(name: "TSOFilesCCSmoke", dependencies: ["TSOFilesC"], path: "Tests/TSOFilesCCSmoke"),
    ],
    swiftLanguageModes: [.v6]
)

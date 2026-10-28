// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Interface",
    products: [
        .library(name: "Interface", targets: ["Interface"]),
        .executable(name: "interface-demo", targets: ["interface-demo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tonytins/raylib-swift", branch: "main"),
    ],
    targets: [
        .target(name: "Interface", dependencies: [.product(name: "Raylib", package: "raylib-swift")]),
        .executableTarget(name: "interface-demo", dependencies: ["Interface", .product(name: "Raylib", package: "raylib-swift")]),
        .testTarget(name: "InterfaceTests", dependencies: ["Interface", .product(name: "Raylib", package: "raylib-swift")]),
    ],
    swiftLanguageModes: [.v6]
)

// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "NSOInterface",
    products: [
        .library(name: "NSOInterface", targets: ["NSOInterface"]),
        .executable(name: "interface-demo", targets: ["interface-demo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tonytins/raylib-swift", branch: "main"),
    ],
    targets: [
        .target(name: "NSOInterface", dependencies: [.product(name: "Raylib", package: "raylib-swift")]),
        .executableTarget(name: "interface-demo", dependencies: ["NSOInterface", .product(name: "Raylib", package: "raylib-swift")]),
        .testTarget(name: "NSOInterfaceTests", dependencies: ["NSOInterface", .product(name: "Raylib", package: "raylib-swift")]),
    ],
    swiftLanguageModes: [.v6]
)

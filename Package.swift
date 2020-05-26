// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MieSockets",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(
            name: "MieSockets",
            targets: ["MieSockets"]),
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/nalexn/ViewInspector", .upToNextMajor(from: "0.3.11")),
    ],
    targets: [
        .target(
            name: "MieSockets",
            dependencies: ["Starscream"]),
        .testTarget(
            name: "MieSocketsTests",
            dependencies: ["MieSockets", "Starscream", "ViewInspector"]),
    ]
)

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DLegBB1",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DLegBB1",
            targets: ["DLegBB1"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apphud/ApphudSDK.git", exact: "3.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DLegBB1",
            dependencies: [
                "ApphudSDK"
            ],
            resources: [
                .process("BassBooster.xcdatamodeld")
            ]
        ),
        .testTarget(
            name: "DLegBB1Tests",
            dependencies: ["DLegBB1"]
        ),
    ]
)

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xAIKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16),
        .visionOS(.v1)
    ],
    products: [
        // Main library
        .library(
            name: "xAIKit",
            targets: ["xAIKit"]
        ),
        // CLI tool for testing
        .executable(
            name: "xai-cli",
            targets: ["xAIKitCLI"]
        )
    ],
    dependencies: [
        // ArgumentParser for CLI
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        // AsyncHTTPClient for Linux support and streaming
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.19.0"),
        // SwiftNIO for advanced networking (required by AsyncHTTPClient)
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.62.0"),
        // swift-docc-plugin for documentation
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // Main library target
        .target(
            name: "xAIKit",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        // CLI executable target
        .executableTarget(
            name: "xAIKitCLI",
            dependencies: [
                "xAIKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        // Test targets
        .testTarget(
            name: "xAIKitTests",
            dependencies: ["xAIKit"]
        ),
        .testTarget(
            name: "xAIKitCLITests",
            dependencies: ["xAIKitCLI"]
        )
    ]
)
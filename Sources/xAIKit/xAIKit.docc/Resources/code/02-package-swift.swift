// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "xAIAssistant",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/yourusername/xAIKit", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "xAIAssistant",
            dependencies: ["xAIKit"]
        )
    ]
)
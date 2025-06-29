import PackageDescription

let package = Package(
    name: "RecipeParser",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "RecipeParser",
            targets: ["RecipeParser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/marcusziade/xAIKit.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "RecipeParser",
            dependencies: ["xAIKit"]),
    ]
)
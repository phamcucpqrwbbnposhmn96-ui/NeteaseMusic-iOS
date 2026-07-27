// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "NeteaseMusic",
    platforms: [.iOS(.v16)],
    products: [
        .executable(name: "NeteaseMusic", targets: ["NeteaseMusic"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "NeteaseMusic",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)

// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "claude-cli",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "claude-cli", path: "Sources/claude-cli")
    ]
)

// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ZeroBlue",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "ZeroBlue", path: "Sources/ZeroBlue")
    ]
)

// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "swift-server",
    dependencies: [
        .package(url: "https://github.com/vapor/multipart.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
    ],
    targets: [
        .target(name: "Server", dependencies: ["Multipart", "Leaf", "Redis", "Vapor"]),
    ]
)


// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "ClipGrid",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "ClipGrid", targets: ["ClipGrid"]),
    ],
    targets: [
        .executableTarget(name: "ClipGrid"),
        .testTarget(name: "ClipGridTests", dependencies: ["ClipGrid"]),
    ]
)

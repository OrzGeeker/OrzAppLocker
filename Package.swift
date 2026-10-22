// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OrzAppLocker",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "OrzAppLocker", targets: ["OrzAppLocker"])
    ],
    dependencies: [
        .package(url: "https://github.com/square/Valet.git", from: "5.1.0")
    ],
    targets: [
        .target(
            name: "OrzAppLocker",
            dependencies: ["Valet"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "OrzAppLockerTests",
            dependencies: ["OrzAppLocker"]
        )
    ]
)

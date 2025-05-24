// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SFSymbolsKit",
    platforms: [.macOS(.v15), .iOS(.v18), .visionOS(.v2)],
    products: [
        .library(
            name: "SFSymbolsKit",
            targets: ["SFSymbolsKit"]
        ),
        .executable(name: "SymbolsExtract", targets: ["SymbolsExtract"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.5.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    ],
    targets: [
        .executableTarget(
            name: "SymbolsExtract",
            dependencies: [
                "SFSymbolsKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "SFSymbolsKit",
            dependencies: [
                .product(name: "GRDB", package: "grdb.swift"),
            ]
        ),
        .testTarget(
            name: "SFSymbolsKitTests",
            dependencies: [
                "SFSymbolsKit",
            ]
        ),
    ]
)

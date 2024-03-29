// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Obfuscate",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "Obfuscate",
            targets: ["Obfuscate"]
        ),
        .executable(
            name: "ObfuscateClient",
            targets: ["ObfuscateClient"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "509.0.0"
        )
    ],
    targets: [
        .macro(
            name: "ObfuscateMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "Obfuscate",
            dependencies: ["ObfuscateMacros"]
        ),
        .executableTarget(
            name: "ObfuscateClient",
            dependencies: ["Obfuscate"]
        ),
        .testTarget(
            name: "ObfuscateTests",
            dependencies: [
                "ObfuscateMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ]
)

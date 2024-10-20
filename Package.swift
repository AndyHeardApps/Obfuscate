// swift-tools-version: 6.0
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
            from: "600.0.0"
        )
    ],
    targets: [
        .macro(
            name: "ObfuscateMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Obfuscate",
            dependencies: ["ObfuscateMacros"],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "ObfuscateClient",
            dependencies: ["Obfuscate"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ObfuscateTests",
            dependencies: [
                "ObfuscateMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ],
            swiftSettings: swiftSettings
        )
    ],
    swiftLanguageModes: [.v6]
)

var swiftSettings: [SwiftSetting] { [
    .enableExperimentalFeature("StrictConcurrency"),
] }

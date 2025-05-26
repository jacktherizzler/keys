// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "kees",
    platforms: [
        .macOS(.v14) // Targeting macOS 14 (Sonoma) or adjust if a different "latest stable" is implied
    ],
    products: [
        .executable(
            name: "kees",
            targets: ["kees"]
        )
    ],
    dependencies: [
        // Add dependencies here if any
    ],
    targets: [
        .executableTarget(
            name: "kees",
            path: "kees", // Points to the kees/kees directory
            resources: [
                // If Assets.xcassets is to be included, it needs to be processed.
                // For simplicity, I'm omitting explicit resource processing here,
                // as SwiftPM handles common resources like .xcassets automatically
                // when they are in the target's path.
                // .process("Assets.xcassets") // Example if explicit processing is needed
            ]
        ),
        .testTarget(
            name: "keesTests",
            dependencies: ["kees"],
            path: "keesTests"
        )
        // UITests are not directly supported by SwiftPM in the same way as .xcodeproj.
        // They usually require an app host. I'll omit the keesUITests target from Package.swift for now.
    ]
)

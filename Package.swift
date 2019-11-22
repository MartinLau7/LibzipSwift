// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LibzipSwift",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
        .macOS(.v10_12),
    ],
    products: [
        .library(name: "libzip", targets: ["libzip"]),
        .library(name: "LibzipSwift", targets: ["LibzipSwift"]),
    ],
    targets: [
        .target(
            name: "libzip",
            path: "Sources/libzip",
            sources: [
                "src",
            ],
            publicHeadersPath: "include",
            cSettings: [
                .define("HAVE_CONFIG_H"),
                .headerSearchPath("include"),
            ],
            linkerSettings: [
                .linkedLibrary("z"),
                .linkedLibrary("bz2"),
            ]
        ),
        .target(
            name: "LibzipSwift",
            dependencies: ["libzip"],
            path: "Sources/LibzipSwift"
        ),
        .testTarget(
            name: "LibzipSwiftTests",
            dependencies: ["LibzipSwift"],
            exclude: ["TestData"]
        )
    ]
)

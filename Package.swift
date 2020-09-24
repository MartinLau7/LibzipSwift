// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Common

private func ruleSets<Element>(_ items: [[Element]]) -> [Element] {
    return items.flatMap { $0 }
}

private func always<Element>(use items: [Element]) -> [Element] {
    return items
}

private func when<Element>(_ condition: Bool, use items: [Element]) -> [Element] {
    if condition {
        return items
    } else {
        return []
    }
}

private enum OSPlatform: Equatable {
    case darwin // macOS, iOS, tvOS, watchOS
    case linux // ubuntu(16/18/20) / Amazon Linux 2
    case windows // windows 10²
    
    #if os(macOS)
    static let current = OSPlatform.darwin
    #elseif os(Linux)
    static let current = OSPlatform.linux
    #else
    #error("Unsupported platform.")
    #endif
}

// MARK: - Package Config

let package = Package(
    name: "LibzipSwift",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(name: "LibzipSwift", targets: ["LibzipSwift"]),
    ],
    dependencies: ruleSets([
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0")
        // when(OSPlatform.current == .linux, use: [
        //     .package(url: "https://github.com/IBM-Swift/OpenSSL.git", from: "2.2.2"),
        // ]),
    ]),
    targets: [
        .target(
            name: "libzip",
            dependencies: [],
            path: "Sources/libzip",
            exclude: ruleSets([
                // always excluded items
                always(use: [
                    // Exclude XZ compression
                    "src/zip_algorithm_xz.c",
                    
                    // Exclude non-CommonCrypto encryption
                    "src/zip_crypto_mbedtls.c",
                    "src/zip_crypto_gnutls.c",
                    "src/zip_crypto_win.c",
                    
                    // Exclude Windows random
                    "src/zip_random_win32.c",
                    "src/zip_random_uwp.c",
                    
                    // Exclude Windows utilities
                    "src/zip_source_win32handle.c",
                    "src/zip_source_win32utf8.c",
                    "src/zip_source_win32a.c",
                    "src/zip_source_win32w.c",
                ]),
                when(OSPlatform.current == .darwin, use: [
                    "src/zip_crypto_openssl.c",
                ]),
                when(OSPlatform.current == .linux, use: [
                    "src/zip_crypto_commoncrypto.c",
                ]),
            ]),
            sources: [
                "src",
            ],
            publicHeadersPath: "include",
            cSettings: [
                .define("HAVE_CONFIG_H"),
                .headerSearchPath("private_include"),
            ],
            linkerSettings: ruleSets([
                always(use: [
                    .linkedLibrary("z"),
                    .linkedLibrary("bz2"),
                ]),
                when(OSPlatform.current == .linux, use: [
                    .linkedLibrary("ssl"),
                    .linkedLibrary("crypto")
                ]),
            ])
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
        ),
    ]
)

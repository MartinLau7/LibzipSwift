// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Common

private enum OSPlatform: Equatable {
    case darwin // macOS, iOS, tvOS, watchOS
    case linux // ubuntu(16/18/20) / Amazon Linux 2
    case windows // windows 10
    
    #if os(macOS)
    static let current = OSPlatform.darwin
    #elseif os(Linux)
    static let current = OSPlatform.linux
    #else
    #error("Unsupported platform.")
    #endif
}

private func ruleSets<Element>(_ items: [[Element]]) -> [Element] {
    return items.flatMap { $0 }
}

private func releDeclaration<Element>(_ items: [Element], when platforms: [OSPlatform]) -> [Element] {
    if !platforms.contains(OSPlatform.current) {
        return []
    }
    return items
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
                [
                    // HAVE_MBEDTLS HAVE_GNUTLS
                    "src/zip_crypto_mbedtls.c",
                    "src/zip_crypto_gnutls.c",
                ],
                releDeclaration([
                    // HAVE_WINDOWS_CRYPTO
                    "src/zip_crypto_win.c",
                    
                    // WIN32
                    "src/zip_random_uwp.c",
                    "src/zip_source_file_win32.c",
                    "src/zip_source_file_win32_named.c",
                    "src/zip_source_file_win32_utf16.c",
                    "src/zip_source_file_win32_utf8.c",
                    "src/zip_source_file_win32_ansi.c",
                    "src/zip_random_win32.c"
                ], when: [.linux, .darwin]),
                
                releDeclaration([
                    // HAVE_COMMONCRYPTO
                    "src/zip_crypto_commoncrypto.c",
                ], when: [.linux]),
                
                releDeclaration([
                    // HAVE_OPENSSL
                    "src/zip_crypto_openssl.c",
                    
                    // HAVE_LIBLZMA
                    // LZMA compression requires LZMA SDK
                    "src/zip_algorithm_xz.c",
                ], when: [.darwin]),
            ]),
            sources: [
                "src",
                ""
            ],
            publicHeadersPath: "include",
            cSettings: ruleSets([
                [
                    .define("HAVE_CONFIG_H"),
                ],
                releDeclaration([
                    .headerSearchPath("private_include/darwin"),
                ], when: [.darwin]),
                releDeclaration([
                    .headerSearchPath("private_include/linux"),
                ], when: [.linux]),
            ]),
            linkerSettings: [
                .linkedLibrary("z"),
                .linkedLibrary("bz2"),
                
                .linkedLibrary("lzma", .when(platforms: [.linux])),
                .linkedLibrary("ssl", .when(platforms: [.linux])),
                .linkedLibrary("crypto", .when(platforms: [.linux])),
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
        ),
    ]
)

// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(macOS)
let excludes = [
    // Exclude XZ compression
    "src/zip_algorithm_xz.c",
    
    // Exclude non-CommonCrypto encryption
    "src/zip_crypto_openssl.c",
    "src/zip_crypto_gnutls.c",
    "src/zip_crypto_mbedtls.c",
    "src/zip_crypto_win.c",
    
    // Exclude Windows random
    "src/zip_random_win32.c",
    "src/zip_random_uwp.c",
    
    // Exclude Windows utilities
    "src/zip_source_win32handle.c",
    "src/zip_source_win32utf8.c",
    "src/zip_source_win32a.c",
    "src/zip_source_win32w.c",
]
#else
let excludes = [
    // Exclude BZ2 compression
//    "src/zip_algorithm_bzip2.c",
    "src/zip_algorithm_xz.c",
    
    // Exclude non-CommonCrypto encryption
    "src/zip_crypto_commoncrypto.c",
    "src/zip_crypto_gnutls.c",
    "src/zip_crypto_mbedtls.c",
    "src/zip_crypto_win.c",
    
    // Exclude Windows random
    "src/zip_random_win32.c",
    "src/zip_random_uwp.c",
    
    // Exclude Windows utilities
//    "src/zip_source_winzip_aes_decode.c",
//    "src/zip_source_winzip_aes_encode.c",
    "src/zip_source_win32handle.c",
    "src/zip_source_win32utf8.c",
    "src/zip_source_win32a.c",
    "src/zip_source_win32w.c",
//    "src/zip_winzip_aes.c"
]
#endif

let package = Package(
    name: "LibzipSwift",
//    platforms: [
//        .iOS(.v11),
//        .tvOS(.v11),
//        .macOS(.v10_12),
//    ],
    products: [
        .library(name: "LibzipSwift", targets: ["LibzipSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        // .package(url: "https://github.com/IBM-Swift/OpenSSL.git", from: "2.2.2")
    ],
    targets: [
        .target(
            name: "libzip",
//            dependencies: ["OpenSSL"],
            path: "Sources/libzip",
            exclude: excludes,
            sources: [
                "src",
            ],
            publicHeadersPath: "include",
            cSettings: [
                .define("HAVE_CONFIG_H"),
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

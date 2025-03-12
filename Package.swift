// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CleverVpnKit",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CleverVpnKit",
            targets: ["CleverVpnKit"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .binaryTarget(
            name: "CleverVpnKit",
            url: "https://github.com/clever-vpn/clevervpn-kit-apple/releases/download/1.0.0/CleverVpnKit.xcframework.zip",
            checksum: "8e2d349c2ded29871638943fe1f29fa2babeea0e3eee46e53a0cb885bce111f0"
        ),
    ]
)

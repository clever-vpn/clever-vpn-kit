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
            checksum: "5aa7d13a93b507e942d74bac94d9b9a0da64308a58fa04180f6c1eed3b0dc9a8"
        ),
    ]
)

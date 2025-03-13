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
            checksum: "7cf84a99c84a2f582cb3ad0ae51bd42f167c493af8e30bdb4fbf1735c885cfd4"
        ),
    ]
)

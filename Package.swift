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
            url: "https://github.com/clever-vpn/clever-vpn-kit/releases/download/v2.1.0/CleverVpnKit.xcframework.zip",
            // path: "../apple/clever-vpn-apple-kit/DistributeTools/output/CleverVpnKit.xcframework.zip",
            checksum: "849d229ee91adc2bca6b80bd020ae4dd3c00b26dee1a6f764943e24854038765"
        ),
    ]
)

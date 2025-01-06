// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "airship_flutter",
    platforms: [.macOS(.v10_15), .iOS(.v14), .tvOS(.v14), .visionOS(.v1)],
    products: [
        .library( name: "airship-flutter", targets: ["airship_flutter"])
    ],
    dependencies: [
        .package(url: "https://github.com/urbanairship/airship-mobile-framework-proxy.git", from: "11.2.1")
    ],
    targets: [
        .target(
            name: "airship_flutter",
            dependencies: [
                .product(name: "AirshipFrameworkProxy", package: "airship-mobile-framework-proxy")
            ],
            resources: [
                 .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VPN Icon",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "VPN Icon",
            targets: ["VPN Icon"]
        )
    ],
    targets: [
        .executableTarget(
            name: "VPN Icon",
            dependencies: [],
            path: "Sources",
            resources: [
                .copy("../Resources/VPN Icon.icns"),
                .copy("../Info.plist")
            ]
        )
    ]
)

// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "XCConfig",
    products: [
        .library(name: "XCConfig", targets: ["XCConfig"]),
    ],
    targets: [
        .target(name: "XCConfig"),
		.testTarget(
			name: "XCConfigTests",
			dependencies: ["XCConfig"],
			resources: [
				.copy("TestData"),
			]
		),
    ]
)

let swiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency")
]

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(contentsOf: swiftSettings)
    target.swiftSettings = settings
}

// swift-tools-version: 6.2
import PackageDescription

let nonisolatedSettings: [SwiftSetting] = [
	.enableExperimentalFeature("ApproachableConcurrency"),
]

let package = Package(
	name: "ChallengeNetworking",
	platforms: [.iOS(.v17)],
	products: [
		.library(name: "ChallengeNetworking", targets: ["ChallengeNetworking"]),
		.library(name: "ChallengeNetworkingMocks", targets: ["ChallengeNetworkingMocks"]),
	],
	dependencies: [
		.package(path: "../Core"),
	],
	targets: [
		.target(
			name: "ChallengeNetworking",
			path: "Sources",
			swiftSettings: nonisolatedSettings
		),
		.target(
			name: "ChallengeNetworkingMocks",
			dependencies: ["ChallengeNetworking"],
			path: "Mocks",
			swiftSettings: nonisolatedSettings
		),
		.testTarget(
			name: "ChallengeNetworkingTests",
			dependencies: [
				"ChallengeNetworking",
				"ChallengeNetworkingMocks",
				.product(name: "ChallengeCoreMocks", package: "Core"),
			],
			path: "Tests",
			swiftSettings: nonisolatedSettings
		),
	]
)

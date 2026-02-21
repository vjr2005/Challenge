// swift-tools-version: 6.2
import PackageDescription

let mainActorSettings: [SwiftSetting] = [
	.defaultIsolation(MainActor.self),
	.enableExperimentalFeature("ApproachableConcurrency"),
]

let package = Package(
	name: "ChallengeAppKit",
	platforms: [.iOS(.v17)],
	products: [
		.library(name: "ChallengeAppKit", targets: ["ChallengeAppKit"]),
	],
	dependencies: [
		.package(path: "../Libraries/Core"),
		.package(path: "../Libraries/Networking"),
		.package(path: "../Features/Home"),
		.package(path: "../Features/Character"),
		.package(path: "../Features/Episode"),
		.package(path: "../Features/System"),
		.package(path: "../Libraries/SnapshotTestKit"),
	],
	targets: [
		.target(
			name: "ChallengeAppKit",
			dependencies: [
				.product(name: "ChallengeCore", package: "Core"),
				.product(name: "ChallengeHome", package: "Home"),
				.product(name: "ChallengeCharacter", package: "Character"),
				.product(name: "ChallengeEpisode", package: "Episode"),
				.product(name: "ChallengeSystem", package: "System"),
				.product(name: "ChallengeNetworking", package: "Networking"),
			],
			path: "Sources",
			swiftSettings: mainActorSettings
		),
		.testTarget(
			name: "ChallengeAppKitTests",
			dependencies: [
				"ChallengeAppKit",
				.product(name: "ChallengeCoreMocks", package: "Core"),
				.product(name: "ChallengeNetworkingMocks", package: "Networking"),
				.product(name: "ChallengeSnapshotTestKit", package: "SnapshotTestKit"),
			],
			path: "Tests",
			exclude: [
				"Snapshots/Presentation/__Snapshots__",
			],
			swiftSettings: mainActorSettings
		),
	]
)

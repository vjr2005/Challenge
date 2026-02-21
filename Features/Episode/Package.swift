// swift-tools-version: 6.2
import PackageDescription

let mainActorSettings: [SwiftSetting] = [
	.defaultIsolation(MainActor.self),
	.enableExperimentalFeature("ApproachableConcurrency"),
]

let package = Package(
	name: "ChallengeEpisode",
	platforms: [.iOS(.v17)],
	products: [
		.library(name: "ChallengeEpisode", targets: ["ChallengeEpisode"]),
	],
	dependencies: [
		.package(path: "../../Libraries/Core"),
		.package(path: "../../Libraries/Networking"),
		.package(path: "../../Shared/Resources"),
		.package(path: "../../Libraries/DesignSystem"),
		.package(path: "../../Libraries/SnapshotTestKit"),
	],
	targets: [
		.target(
			name: "ChallengeEpisode",
			dependencies: [
				.product(name: "ChallengeCore", package: "Core"),
				.product(name: "ChallengeDesignSystem", package: "DesignSystem"),
				.product(name: "ChallengeNetworking", package: "Networking"),
				.product(name: "ChallengeResources", package: "Resources"),
			],
			path: "Sources",
			swiftSettings: mainActorSettings
		),
		.testTarget(
			name: "ChallengeEpisodeTests",
			dependencies: [
				"ChallengeEpisode",
				.product(name: "ChallengeCoreMocks", package: "Core"),
				.product(name: "ChallengeNetworkingMocks", package: "Networking"),
				.product(name: "ChallengeSnapshotTestKit", package: "SnapshotTestKit"),
			],
			path: "Tests",
			exclude: [
				"Snapshots/Presentation/CharacterEpisodes/__Snapshots__",
			],
			resources: [
				.process("Shared/Fixtures"),
				.process("Shared/Resources"),
			],
			swiftSettings: mainActorSettings
		),
	]
)

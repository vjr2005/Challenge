// swift-tools-version: 6.2
import PackageDescription

let mainActorSettings: [SwiftSetting] = [
	.defaultIsolation(MainActor.self),
	.enableExperimentalFeature("ApproachableConcurrency"),
]

let package = Package(
	name: "ChallengeCharacter",
	platforms: [.iOS(.v17)],
	products: [
		.library(name: "ChallengeCharacter", targets: ["ChallengeCharacter"]),
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
			name: "ChallengeCharacter",
			dependencies: [
				.product(name: "ChallengeCore", package: "Core"),
				.product(name: "ChallengeNetworking", package: "Networking"),
				.product(name: "ChallengeResources", package: "Resources"),
				.product(name: "ChallengeDesignSystem", package: "DesignSystem"),
			],
			path: "Sources",
			swiftSettings: mainActorSettings
		),
		.testTarget(
			name: "ChallengeCharacterTests",
			dependencies: [
				"ChallengeCharacter",
				.product(name: "ChallengeCoreMocks", package: "Core"),
				.product(name: "ChallengeNetworkingMocks", package: "Networking"),
				.product(name: "ChallengeSnapshotTestKit", package: "SnapshotTestKit"),
			],
			path: "Tests",
			exclude: [
				"Snapshots/Presentation/CharacterDetail/__Snapshots__",
				"Snapshots/Presentation/CharacterFilter/__Snapshots__",
				"Snapshots/Presentation/CharacterList/__Snapshots__",
			],
			resources: [
				.process("Shared/Fixtures"),
				.process("Shared/Resources"),
			],
			swiftSettings: mainActorSettings
		),
	]
)

// swift-tools-version: 6.2
import PackageDescription

let mainActorSettings: [SwiftSetting] = [
	.defaultIsolation(MainActor.self),
	.enableExperimentalFeature("ApproachableConcurrency"),
]

let package = Package(
	name: "ChallengeDesignSystem",
	platforms: [.iOS(.v17)],
	products: [
		.library(name: "ChallengeDesignSystem", targets: ["ChallengeDesignSystem"]),
	],
	dependencies: [
		.package(path: "../Core"),
		.package(path: "../SnapshotTestKit"),
	],
	targets: [
		.target(
			name: "ChallengeDesignSystem",
			dependencies: [
				.product(name: "ChallengeCore", package: "Core"),
			],
			path: "Sources",
			swiftSettings: mainActorSettings
		),
		.testTarget(
			name: "ChallengeDesignSystemTests",
			dependencies: [
				"ChallengeDesignSystem",
				.product(name: "ChallengeCoreMocks", package: "Core"),
				.product(name: "ChallengeSnapshotTestKit", package: "SnapshotTestKit"),
			],
			path: "Tests",
			exclude: [
				"Snapshots/Atoms/__Snapshots__",
				"Snapshots/Extensions/__Snapshots__",
				"Snapshots/Molecules/__Snapshots__",
				"Snapshots/Organisms/__Snapshots__",
				"Snapshots/Theme/__Snapshots__",
			],
			resources: [
				.process("Shared/Resources"),
			],
			swiftSettings: mainActorSettings
		),
	]
)

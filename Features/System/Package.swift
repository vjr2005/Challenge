// swift-tools-version: 6.2
import PackageDescription

let mainActorSettings: [SwiftSetting] = [
	.defaultIsolation(MainActor.self),
	.enableExperimentalFeature("ApproachableConcurrency"),
]

let package = Package(
	name: "ChallengeSystem",
	platforms: [.iOS(.v17)],
	products: [
		.library(name: "ChallengeSystem", targets: ["ChallengeSystem"]),
	],
	dependencies: [
		.package(path: "../../Libraries/Core"),
		.package(path: "../../Shared/Resources"),
		.package(path: "../../Libraries/DesignSystem"),
		.package(path: "../../Libraries/SnapshotTestKit"),
	],
	targets: [
		.target(
			name: "ChallengeSystem",
			dependencies: [
				.product(name: "ChallengeCore", package: "Core"),
				.product(name: "ChallengeResources", package: "Resources"),
				.product(name: "ChallengeDesignSystem", package: "DesignSystem"),
			],
			path: "Sources",
			swiftSettings: mainActorSettings
		),
		.testTarget(
			name: "ChallengeSystemTests",
			dependencies: [
				"ChallengeSystem",
				.product(name: "ChallengeCoreMocks", package: "Core"),
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

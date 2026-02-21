// swift-tools-version: 6.2
import PackageDescription

let mainActorSettings: [SwiftSetting] = [
	.defaultIsolation(MainActor.self),
	.enableExperimentalFeature("ApproachableConcurrency"),
]

let package = Package(
	name: "ChallengeHome",
	platforms: [.iOS(.v17)],
	products: [
		.library(name: "ChallengeHome", targets: ["ChallengeHome"]),
	],
	dependencies: [
		.package(path: "../../Libraries/Core"),
		.package(path: "../../Libraries/DesignSystem"),
		.package(path: "../../Shared/Resources"),
		.package(url: "https://github.com/airbnb/lottie-ios", from: "4.6.0"),
		.package(path: "../../Libraries/SnapshotTestKit"),
	],
	targets: [
		.target(
			name: "ChallengeHome",
			dependencies: [
				.product(name: "ChallengeCore", package: "Core"),
				.product(name: "ChallengeDesignSystem", package: "DesignSystem"),
				.product(name: "ChallengeResources", package: "Resources"),
				.product(name: "Lottie", package: "lottie-ios"),
			],
			path: "Sources",
			resources: [
				.process("Resources"),
			],
			swiftSettings: mainActorSettings
		),
		.testTarget(
			name: "ChallengeHomeTests",
			dependencies: [
				"ChallengeHome",
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

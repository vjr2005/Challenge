// swift-tools-version: 6.2
import PackageDescription

let mainActorSettings: [SwiftSetting] = [
	.defaultIsolation(MainActor.self),
	.enableExperimentalFeature("ApproachableConcurrency"),
]

let package = Package(
	name: "ChallengeCore",
	platforms: [.iOS(.v17)],
	products: [
		.library(name: "ChallengeCore", targets: ["ChallengeCore"]),
		.library(name: "ChallengeCoreMocks", targets: ["ChallengeCoreMocks"]),
	],
	targets: [
		.target(
			name: "ChallengeCore",
			path: "Sources",
			swiftSettings: mainActorSettings
		),
		.target(
			name: "ChallengeCoreMocks",
			dependencies: ["ChallengeCore"],
			path: "Mocks",
			swiftSettings: mainActorSettings
		),
		.testTarget(
			name: "ChallengeCoreTests",
			dependencies: ["ChallengeCore", "ChallengeCoreMocks"],
			path: "Tests",
			swiftSettings: mainActorSettings
		),
	]
)

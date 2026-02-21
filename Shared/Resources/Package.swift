// swift-tools-version: 6.2
import PackageDescription

let mainActorSettings: [SwiftSetting] = [
	.defaultIsolation(MainActor.self),
	.enableExperimentalFeature("ApproachableConcurrency"),
]

let package = Package(
	name: "ChallengeResources",
	platforms: [.iOS(.v17)],
	products: [
		.library(name: "ChallengeResources", targets: ["ChallengeResources"]),
	],
	dependencies: [
		.package(path: "../../Libraries/Core"),
	],
	targets: [
		.target(
			name: "ChallengeResources",
			dependencies: [
				.product(name: "ChallengeCore", package: "Core"),
			],
			path: "Sources",
			resources: [
				.process("Resources"),
			],
			swiftSettings: mainActorSettings
		),
	]
)

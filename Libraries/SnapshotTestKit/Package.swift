// swift-tools-version: 6.2
import PackageDescription

let mainActorSettings: [SwiftSetting] = [
	.defaultIsolation(MainActor.self),
	.enableExperimentalFeature("ApproachableConcurrency"),
]

let package = Package(
	name: "ChallengeSnapshotTestKit",
	platforms: [.iOS(.v17)],
	products: [
		.library(name: "ChallengeSnapshotTestKit", targets: ["ChallengeSnapshotTestKit"]),
	],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0"),
	],
	targets: [
		.target(
			name: "ChallengeSnapshotTestKit",
			dependencies: [
				.product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
			],
			path: "Sources",
			swiftSettings: mainActorSettings
		),
	]
)

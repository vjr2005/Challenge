// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import ProjectDescription
import ProjectDescriptionHelpers

let packageSettings = PackageSettings(
	productTypes: [
		"SnapshotTesting": .framework,
		"SwiftMockServerBinary": .framework,
	],
	baseSettings: .settings(
		configurations: BuildConfiguration.all
	)
)
#endif

let package = Package(
	name: "ChallengePackages",
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0"),
		.package(url: "https://github.com/airbnb/lottie-ios", from: "4.6.0"),
		.package(url: "https://github.com/vjr2005/SwiftMockServer", from: "1.1.1"),
	]
)

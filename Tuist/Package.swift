// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import ProjectDescription
import ProjectDescriptionHelpers

let nonisolatedSettings: SettingsDictionary = projectBaseSettings.merging([
	"SWIFT_DEFAULT_ACTOR_ISOLATION": .string("nonisolated"),
]) { _, new in new }

let snapshotTestKitSettings: SettingsDictionary = projectBaseSettings.merging([
	"ENABLE_TESTING_SEARCH_PATHS": "YES",
]) { _, new in new }

let packageSettings = PackageSettings(
	productTypes: [
		// Local packages
		"ChallengeCore": .framework,
		"ChallengeCoreMocks": .framework,
		"ChallengeNetworking": .framework,
		"ChallengeNetworkingMocks": .framework,
		"ChallengeSnapshotTestKit": .framework,
		"ChallengeDesignSystem": .framework,
		"ChallengeResources": .framework,
		"ChallengeCharacter": .framework,
		"ChallengeEpisode": .framework,
		"ChallengeHome": .framework,
		"ChallengeSystem": .framework,
		"ChallengeAppKit": .framework,
		// External packages
		"SnapshotTesting": .framework,
		"SwiftMockServerBinary": .framework,
	],
	baseSettings: .settings(
		configurations: BuildConfiguration.all
	),
	targetSettings: [
		// MainActor-default targets
		"ChallengeCore": .settings(base: projectBaseSettings),
		"ChallengeCoreMocks": .settings(base: projectBaseSettings),
		"ChallengeDesignSystem": .settings(base: projectBaseSettings),
		"ChallengeResources": .settings(base: projectBaseSettings),
		"ChallengeCharacter": .settings(base: projectBaseSettings),
		"ChallengeEpisode": .settings(base: projectBaseSettings),
		"ChallengeHome": .settings(base: projectBaseSettings),
		"ChallengeSystem": .settings(base: projectBaseSettings),
		"ChallengeAppKit": .settings(base: projectBaseSettings),
		// Nonisolated targets
		"ChallengeNetworking": .settings(base: nonisolatedSettings),
		"ChallengeNetworkingMocks": .settings(base: nonisolatedSettings),
		// SnapshotTestKit
		"ChallengeSnapshotTestKit": .settings(base: snapshotTestKitSettings),
	]
)
#endif

let package = Package(
	name: "ChallengePackages",
	dependencies: [
		// Local packages
		.package(path: "../Libraries/Core"),
		.package(path: "../Libraries/Networking"),
		.package(path: "../Libraries/SnapshotTestKit"),
		.package(path: "../Libraries/DesignSystem"),
		.package(path: "../Shared/Resources"),
		.package(path: "../Features/Character"),
		.package(path: "../Features/Episode"),
		.package(path: "../Features/Home"),
		.package(path: "../Features/System"),
		.package(path: "../AppKit"),
		// External packages
		.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0"),
		.package(url: "https://github.com/airbnb/lottie-ios", from: "4.6.0"),
		.package(url: "https://github.com/vjr2005/SwiftMockServer", from: "1.1.1"),
	]
)

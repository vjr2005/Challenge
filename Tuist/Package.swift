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
		"ChallengeCoreTests": .settings(base: projectBaseSettings),
		"ChallengeDesignSystem": .settings(base: projectBaseSettings),
		"ChallengeDesignSystemTests": .settings(base: projectBaseSettings),
		"ChallengeResources": .settings(base: projectBaseSettings),
		"ChallengeCharacter": .settings(base: projectBaseSettings),
		"ChallengeCharacterTests": .settings(base: projectBaseSettings),
		"ChallengeEpisode": .settings(base: projectBaseSettings),
		"ChallengeEpisodeTests": .settings(base: projectBaseSettings),
		"ChallengeHome": .settings(base: projectBaseSettings),
		"ChallengeHomeTests": .settings(base: projectBaseSettings),
		"ChallengeSystem": .settings(base: projectBaseSettings),
		"ChallengeSystemTests": .settings(base: projectBaseSettings),
		"ChallengeAppKit": .settings(base: projectBaseSettings),
		"ChallengeAppKitTests": .settings(base: projectBaseSettings),
		// Nonisolated targets
		"ChallengeNetworking": .settings(base: nonisolatedSettings),
		"ChallengeNetworkingMocks": .settings(base: nonisolatedSettings),
		"ChallengeNetworkingTests": .settings(base: nonisolatedSettings),
		// SnapshotTestKit
		"ChallengeSnapshotTestKit": .settings(base: snapshotTestKitSettings),
	]
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

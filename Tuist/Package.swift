// swift-tools-version: 6.4
import PackageDescription

#if TUIST
import ProjectDescription
import ProjectDescriptionHelpers

// Xcode 27 rejects deployment targets below iOS 15, but these packages declare iOS 13.
// Package platforms override project-level settings, so the override is per target.
let legacyDeploymentTargetSettings: [String: Settings] = Dictionary(
	uniqueKeysWithValues: ["Lottie", "SnapshotTesting"].map {
		(
			$0,
			Settings.settings(base: ["IPHONEOS_DEPLOYMENT_TARGET": .string("\(projectConfig.iosMajorVersion).0")])
		)
	}
)

let packageSettings = PackageSettings(
	productTypes: allExternalPackages.productTypes,
	baseSettings: .settings(
		configurations: BuildConfiguration.all
	),
	targetSettings: legacyDeploymentTargetSettings.merging(mainApp.packageTargetSettings) { _, new in new }
)

let package = PackageDescription.Package(
	name: "ChallengePackages",
	dependencies: allExternalPackages.map {
		.package(url: $0.url, from: Version(stringLiteral: $0.version))
	}
)
#else
// Hardcoded fallback for `tuist install` which runs pure SPM
// without access to ProjectDescriptionHelpers.
// ⚠️ Keep URLs and versions in sync with ExternalPackages.swift.
let package = Package(
	name: "ChallengePackages",
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.6"),
		.package(url: "https://github.com/airbnb/lottie-ios", from: "4.6.1"),
		.package(url: "https://github.com/vjr2005/SwiftMockServer", from: "1.1.1"),
	]
)
#endif

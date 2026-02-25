// swift-tools-version: 6.2
import PackageDescription

#if TUIST
import ProjectDescription
import ProjectDescriptionHelpers

let packageSettings = PackageSettings(
	productTypes: allExternalPackages.productTypes,
	baseSettings: .settings(
		configurations: BuildConfiguration.all
	),
	targetSettings: mainApp.packageTargetSettings
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
		.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0"),
		.package(url: "https://github.com/airbnb/lottie-ios", from: "4.6.0"),
		.package(url: "https://github.com/vjr2005/SwiftMockServer", from: "1.1.1"),
	]
)
#endif

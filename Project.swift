import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - App Target

let appInfoPlist: [String: Plist.Value] = [
	"CFBundleLocalizations": ["en", "es"],
	"UILaunchStoryboardName": "LaunchScreen",
	"UISupportedInterfaceOrientations": [
		"UIInterfaceOrientationPortrait",
		"UIInterfaceOrientationLandscapeLeft",
		"UIInterfaceOrientationLandscapeRight",
		"UIInterfaceOrientationPortraitUpsideDown",
	],
	"UISupportedInterfaceOrientations~ipad": [
		"UIInterfaceOrientationPortrait",
		"UIInterfaceOrientationPortraitUpsideDown",
		"UIInterfaceOrientationLandscapeLeft",
		"UIInterfaceOrientationLandscapeRight",
	],
	"CFBundleURLTypes": [
		[
			"CFBundleURLSchemes": ["challenge"],
			"CFBundleURLName": "com.app.Challenge",
		],
	],
]

let appTarget = Target.target(
	name: appName,
	destinations: destinations,
	product: .app,
	bundleId: "com.app.\(appName)",
	deploymentTargets: developmentTarget,
	infoPlist: .extendingDefault(with: appInfoPlist),
	sources: ["App/Sources/**"],
	resources: ["App/Sources/Resources/**"],
	scripts: [SwiftLint.script(path: "App/Sources")],
	dependencies: Modules.appDependencies,
	settings: .settings(
		configurations: Environment.appTargetConfigurations,
		defaultSettings: .recommended
	)
)

let appUITestsTarget = Target.target(
	name: "\(appName)UITests",
	destinations: destinations,
	product: .uiTests,
	bundleId: "com.app.\(appName)UITests",
	deploymentTargets: developmentTarget,
	infoPlist: .default,
	sources: [
		"App/Tests/UI/**",
		"App/Tests/Shared/**",
	],
	resources: [
		"App/Tests/Shared/Fixtures/**",
		"App/Tests/Shared/Resources/**",
	],
	dependencies: [
		.target(name: appName),
		.external(name: "SwiftMockServerBinary"),
	]
)

// MARK: - Project

let project = Project(
	name: appName,
	options: .options(
		automaticSchemesOptions: .disabled,
		developmentRegion: "en",
		disableBundleAccessors: true,
		disableSynthesizedResourceAccessors: true
	),
	settings: .settings(
		base: projectBaseSettings.merging([
			// Generates Swift symbols for localized strings in String Catalogs
			"SWIFT_EMIT_LOC_STRINGS": .string("YES"),
		]) { _, new in new },
		configurations: BuildConfiguration.all
	),
	targets: [appTarget, appUITestsTarget]
)

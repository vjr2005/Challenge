import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - App Target

let appInfoPlist: [String: Plist.Value] = [
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

let appTestsTarget = Target.target(
	name: "\(appName)Tests",
	destinations: destinations,
	product: .unitTests,
	bundleId: "com.app.\(appName)Tests",
	deploymentTargets: developmentTarget,
	infoPlist: .default,
	sources: ["App/Tests/**"],
	dependencies: [
		.target(name: appName),
		.target(name: "\(appName)Core"),
	]
)

let appE2ETestsTarget = Target.target(
	name: "\(appName)E2ETests",
	destinations: destinations,
	product: .uiTests,
	bundleId: "com.app.\(appName)E2ETests",
	deploymentTargets: developmentTarget,
	infoPlist: .default,
	sources: ["App/E2ETests/**"],
	dependencies: [.target(name: appName)]
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
		base: [
			"SWIFT_VERSION": .string(swiftVersion),
			"SWIFT_APPROACHABLE_CONCURRENCY": .string("YES"),
			"SWIFT_DEFAULT_ACTOR_ISOLATION": .string("MainActor"),
		],
		configurations: BuildConfiguration.all
	),
	targets: [appTarget, appTestsTarget, appE2ETestsTarget] + Modules.targets,
	schemes: AppScheme.allSchemes(testTargets: ["\(appName)Tests", "\(appName)E2ETests"]) + Modules.schemes
)

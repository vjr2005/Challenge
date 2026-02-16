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

let appUITestsScheme = Scheme.scheme(
	name: "\(appName)UITests",
	buildAction: .buildAction(targets: [.target(appName), .target("\(appName)UITests")]),
	testAction: .targets(
		["\(appName)UITests"],
		options: .options(
			preferredScreenCaptureFormat: .screenRecording,
			coverage: true,
			codeCoverageTargets: Modules.codeCoverageTargets
		)
	)
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
			// Sets the Swift language version for compilation
			"SWIFT_VERSION": .string(swiftVersion),
			// Enables implicit Sendable conformance for MainActor-isolated types
			"SWIFT_APPROACHABLE_CONCURRENCY": .string("YES"),
			// Makes all declarations MainActor-isolated by default (opt-out with nonisolated)
			"SWIFT_DEFAULT_ACTOR_ISOLATION": .string("MainActor"),
			// Generates Swift symbols for localized strings in String Catalogs
			"SWIFT_EMIT_LOC_STRINGS": .string("YES"),
			// Disabled: SwiftLint script requires access to mise outside the sandbox
			"ENABLE_USER_SCRIPT_SANDBOXING": .string("NO"),
		],
		configurations: BuildConfiguration.all
	),
	targets: [appTarget, appUITestsTarget] + Modules.targets,
	schemes: AppScheme.allSchemes() + [appUITestsScheme] + Modules.schemes
)

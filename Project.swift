import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Framework Modules

let coreModule = FrameworkModule.create(name: "Core")
let networkingModule = FrameworkModule.create(name: "Networking")
let appConfigurationModule = FrameworkModule.create(name: "AppConfiguration", hasMocks: false)

let characterModule = FrameworkModule.create(
	name: "Character",
	path: "Features/Character",
	dependencies: [
		.target(name: "\(appName)Core"),
		.target(name: "\(appName)Networking"),
		.target(name: "\(appName)AppConfiguration"),
	],
	testDependencies: [
		.target(name: "\(appName)CoreMocks"),
		.target(name: "\(appName)NetworkingMocks"),
		.external(name: "SnapshotTesting"),
	],
	hasMocks: false
)

let homeModule = FrameworkModule.create(
	name: "Home",
	path: "Features/Home",
	dependencies: [
		.target(name: "\(appName)Core"),
		.target(name: "\(appName)Character"),
	],
	testDependencies: [
		.target(name: "\(appName)CoreMocks"),
		.external(name: "SnapshotTesting"),
	],
	hasMocks: false
)

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
	dependencies: [
		.target(name: "\(appName)Core"),
		.target(name: "\(appName)Character"),
		.target(name: "\(appName)Home"),
	],
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
	sources: ["App/Tests/**"]
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

let allModuleTargets = coreModule.targets
	+ networkingModule.targets
	+ appConfigurationModule.targets
	+ characterModule.targets
	+ homeModule.targets

let allModuleSchemes = coreModule.schemes
	+ networkingModule.schemes
	+ appConfigurationModule.schemes
	+ characterModule.schemes
	+ homeModule.schemes

let project = Project(
	name: appName,
	options: .options(automaticSchemesOptions: .disabled),
	settings: .settings(
		base: [
			"SWIFT_VERSION": .string(swiftVersion),
			"SWIFT_APPROACHABLE_CONCURRENCY": .string("YES"),
			"SWIFT_DEFAULT_ACTOR_ISOLATION": .string("MainActor"),
		],
		configurations: BuildConfiguration.all
	),
	targets: [appTarget, appTestsTarget, appE2ETestsTarget] + allModuleTargets,
	schemes: AppScheme.allSchemes(testTargets: ["\(appName)Tests", "\(appName)E2ETests"]) + allModuleSchemes
)

import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Build Configurations

let debugConfiguration: Configuration = .debug(
	name: "Debug",
	settings: [
		"SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG",
	]
)

let debugStagingConfiguration: Configuration = .debug(
	name: "Debug-Staging",
	settings: [
		"SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG DEBUG_STAGING",
	]
)

let debugProdConfiguration: Configuration = .debug(
	name: "Debug-Prod",
	settings: [
		"SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG DEBUG_PROD",
	]
)

let stagingConfiguration: Configuration = .release(
	name: "Staging",
	settings: [
		"SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) STAGING",
	]
)

let releaseConfiguration: Configuration = .release(
	name: "Release",
	settings: [
		"SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) PRODUCTION",
	]
)

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

// MARK: - App Targets

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

let appDependencies: [TargetDependency] = [
	.target(name: "\(appName)Core"),
	.target(name: "\(appName)Character"),
	.target(name: "\(appName)Home"),
]

let appTarget = Target.target(
	name: appName,
	destinations: [.iPhone, .iPad],
	product: .app,
	bundleId: "com.app.\(appName)",
	deploymentTargets: developmentTarget,
	infoPlist: .extendingDefault(with: appInfoPlist),
	sources: ["App/Sources/**"],
	resources: ["App/Sources/Resources/**"],
	scripts: [SwiftLint.script(path: "App/Sources")],
	dependencies: appDependencies,
	settings: .settings(
		configurations: [
			.debug(
				name: "Debug",
				settings: [
					"PRODUCT_BUNDLE_IDENTIFIER": "com.app.\(appName).dev",
					"ASSETCATALOG_COMPILER_APPICON_NAME": "AppIconDev",
				]
			),
			.debug(
				name: "Debug-Staging",
				settings: [
					"PRODUCT_BUNDLE_IDENTIFIER": "com.app.\(appName).staging",
					"ASSETCATALOG_COMPILER_APPICON_NAME": "AppIconStaging",
				]
			),
			.debug(
				name: "Debug-Prod",
				settings: [
					"PRODUCT_BUNDLE_IDENTIFIER": "com.app.\(appName)",
					"ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
				]
			),
			.release(
				name: "Staging",
				settings: [
					"PRODUCT_BUNDLE_IDENTIFIER": "com.app.\(appName).staging",
					"ASSETCATALOG_COMPILER_APPICON_NAME": "AppIconStaging",
				]
			),
			.release(
				name: "Release",
				settings: [
					"PRODUCT_BUNDLE_IDENTIFIER": "com.app.\(appName)",
					"ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
				]
			),
		],
		defaultSettings: .recommended
	)
)

// MARK: - Project

let appTestsTarget: TestableTarget = "\(appName)Tests"
let appE2ETestsTarget: TestableTarget = "\(appName)E2ETests"

let project = Project(
	name: appName,
	options: .options(
		automaticSchemesOptions: .disabled
	),
	settings: .settings(
		base: [
			"SWIFT_VERSION": .string(swiftVersion),
			"SWIFT_APPROACHABLE_CONCURRENCY": .string("YES"),
			"SWIFT_DEFAULT_ACTOR_ISOLATION": .string("MainActor"),
		],
		configurations: [
			debugConfiguration,
			debugStagingConfiguration,
			debugProdConfiguration,
			stagingConfiguration,
			releaseConfiguration,
		]
	),
	targets: [
		appTarget,
		.target(
			name: "\(appName)Tests",
			destinations: [.iPhone, .iPad],
			product: .unitTests,
			bundleId: "com.app.\(appName)Tests",
			deploymentTargets: developmentTarget,
			infoPlist: .default,
			sources: ["App/Tests/**"]
		),
		.target(
			name: "\(appName)E2ETests",
			destinations: [.iPhone, .iPad],
			product: .uiTests,
			bundleId: "com.app.\(appName)E2ETests",
			deploymentTargets: developmentTarget,
			infoPlist: .default,
			sources: ["App/E2ETests/**"],
			dependencies: [
				.target(name: appName),
			]
		),
	] + coreModule.targets + networkingModule.targets + appConfigurationModule.targets + characterModule.targets + homeModule.targets,
	schemes: [
		.scheme(
			name: "\(appName) (Dev)",
			buildAction: .buildAction(targets: [.target(appName)]),
			testAction: .targets(
				[appTestsTarget, appE2ETestsTarget],
				configuration: "Debug",
				options: .options(coverage: true)
			),
			runAction: .runAction(
				configuration: "Debug",
				executable: .target(appName)
			),
			archiveAction: .archiveAction(configuration: "Release"),
			profileAction: .profileAction(configuration: "Release", executable: .target(appName)),
			analyzeAction: .analyzeAction(configuration: "Debug")
		),
		.scheme(
			name: "\(appName) (Staging)",
			buildAction: .buildAction(targets: [.target(appName)]),
			runAction: .runAction(
				configuration: "Debug-Staging",
				executable: .target(appName)
			),
			archiveAction: .archiveAction(configuration: "Staging"),
			profileAction: .profileAction(configuration: "Staging", executable: .target(appName)),
			analyzeAction: .analyzeAction(configuration: "Debug-Staging")
		),
		.scheme(
			name: "\(appName) (Prod)",
			buildAction: .buildAction(targets: [.target(appName)]),
			runAction: .runAction(
				configuration: "Debug-Prod",
				executable: .target(appName)
			),
			archiveAction: .archiveAction(configuration: "Release"),
			profileAction: .profileAction(configuration: "Release", executable: .target(appName)),
			analyzeAction: .analyzeAction(configuration: "Debug-Prod")
		),
	] + coreModule.schemes + networkingModule.schemes + appConfigurationModule.schemes + characterModule.schemes + homeModule.schemes
)

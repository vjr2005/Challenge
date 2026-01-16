import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Framework Modules

let coreModule = FrameworkModule.create(name: "Core")
let networkingModule = FrameworkModule.create(name: "Networking")
let characterModule = FrameworkModule.create(
	name: "Character",
	path: "Features/Character",
	dependencies: [
		.target(name: "\(appName)Core"),
		.target(name: "\(appName)Networking"),
	],
	testDependencies: [
		.target(name: "\(appName)CoreMocks"),
		.target(name: "\(appName)NetworkingMocks"),
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
	],
	hasMocks: false
)

// MARK: - Project

let appTestsTarget: TestableTarget = "\(appName)Tests"

let project = Project(
	name: appName,
	settings: .settings(
		base: [
			"SWIFT_VERSION": .string(swiftVersion),
			"SWIFT_APPROACHABLE_CONCURRENCY": .string("YES"),
			"SWIFT_DEFAULT_ACTOR_ISOLATION": .string("MainActor"),
		]
	),
	targets: [
		.target(
			name: appName,
			destinations: [.iPhone, .iPad],
			product: .app,
			bundleId: "com.app.\(appName)",
			deploymentTargets: developmentTarget,
			infoPlist: .extendingDefault(with: [
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
			]),
			sources: ["App/Sources/**"],
			resources: ["App/Sources/Resources/**"],
			scripts: [SwiftLint.script(path: "App/Sources")],
			dependencies: [
				.target(name: "\(appName)Core"),
				.target(name: "\(appName)Character"),
				.target(name: "\(appName)Home"),
			]
		),
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
			name: "\(appName)UITests",
			destinations: [.iPhone, .iPad],
			product: .uiTests,
			bundleId: "com.app.\(appName)UITests",
			deploymentTargets: developmentTarget,
			infoPlist: .default,
			sources: ["App/UITests/**"]
		),
	] + coreModule.targets + networkingModule.targets + characterModule.targets + homeModule.targets,
	schemes: [
		.scheme(
			name: appName,
			buildAction: .buildAction(targets: [.target(appName)]),
			testAction: .targets(
				[appTestsTarget],
				options: .options(coverage: true)
			),
			runAction: .runAction(executable: .target(appName))
		),
	] + coreModule.schemes + networkingModule.schemes + characterModule.schemes + homeModule.schemes
)

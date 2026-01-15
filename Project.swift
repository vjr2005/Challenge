import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Framework Modules

let networkingModule = FrameworkModule.create(name: "Networking")

// MARK: - Project

let appTestsTarget: TestableTarget = "\(appName)Tests"

let project = Project(
	name: appName,
	settings: .settings(
		base: ["SWIFT_VERSION": .string(swiftVersion)]
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
			resources: ["App/Sources/Resources/**"]
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
	] + networkingModule.targets,
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
	] + networkingModule.schemes
)

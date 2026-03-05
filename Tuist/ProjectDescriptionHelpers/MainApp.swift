import ProjectDescription

private let appBundleId = "com.app.\(projectConfig.appName)"

/// The app instance shared across all manifest files.
public let mainApp = App(
	name: projectConfig.appName,
	bundleId: appBundleId,
	destinations: projectConfig.destinations,
	developmentTarget: projectConfig.developmentTarget,
	baseSettings: projectConfig.baseSettings,
	infoPlist: [
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
				"CFBundleURLName": .string(appBundleId),
			],
		],
	],
	modules: [
		coreModule,
		networkingModule,
		snapshotTestKitModule,
		designSystemModule,
		resourcesModule,
		characterModule,
		episodeModule,
		homeModule,
		systemModule,
		appKitModule,
	],
	entryModule: appKitModule
)

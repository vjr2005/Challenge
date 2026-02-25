import ProjectDescription

/// The app instance shared across all manifest files.
public let mainApp = App(
	name: projectConfig.appName,
	bundleId: "com.app.\(projectConfig.appName)",
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
				"CFBundleURLName": "com.app.Challenge",
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

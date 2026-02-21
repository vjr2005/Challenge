import ProjectDescription

/// Configuration and targets for the main app project.
public enum App {
	/// Target reference for the main app target.
	static var targetReference: TargetReference {
		.target(appName)
	}

	/// Target reference for the UI tests target.
	static var uiTestsTargetReference: TargetReference {
		.target("\(appName)UITests")
	}

	/// App dependencies (modules that the app target depends on).
	private static var dependencies: [TargetDependency] {
		[appKitModule.targetDependency]
	}

	/// All testable targets across all modules.
	static var testableTargets: [TestableTarget] {
		Modules.testableTargets
	}

	// MARK: - Targets

	private static let infoPlist: [String: Plist.Value] = [
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

	private static var appTarget: Target {
		.target(
			name: appName,
			destinations: destinations,
			product: .app,
			bundleId: "com.app.\(appName)",
			deploymentTargets: developmentTarget,
			infoPlist: .extendingDefault(with: infoPlist),
			sources: ["App/Sources/**"],
			resources: ["App/Sources/Resources/**"],
			scripts: [SwiftLint.script(path: "App/Sources")],
			dependencies: dependencies,
			settings: .settings(
				configurations: Environment.appTargetConfigurations,
				defaultSettings: .recommended
			)
		)
	}

	private static var uiTestsTarget: Target {
		.target(
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
	}

	// MARK: - Project

	/// The main app project.
	public static var project: Project {
		Project(
			name: appName,
			options: .options(
				automaticSchemesOptions: .disabled,
				developmentRegion: "en",
				disableBundleAccessors: true,
				disableSynthesizedResourceAccessors: true
			),
			settings: .settings(
				base: projectBaseSettings.merging([
					"SWIFT_EMIT_LOC_STRINGS": .string("YES"),
				]) { _, new in new },
				configurations: BuildConfiguration.all
			),
			targets: [appTarget, uiTestsTarget] + Modules.testTargets,
			schemes: AppScheme.allSchemes() + [AppScheme.uiTestsScheme(), AppScheme.moduleTestsScheme()]
				+ Modules.testSchemes
		)
	}
}

import ProjectDescription

/// Configuration and targets for the main app project.
public enum App {
	/// Path to the main app project (workspace root).
	private static let projectPath: ProjectDescription.Path = .relativeToRoot(".")

	/// Cross-project target reference for the main app target (workspace-level schemes).
	static var targetReference: TargetReference {
		.project(path: projectPath, target: appName)
	}

	/// Cross-project target reference for the UI tests target (workspace-level schemes).
	static var uiTestsTargetReference: TargetReference {
		.project(path: projectPath, target: "\(appName)UITests")
	}

	/// App dependencies (modules that the app target depends on).
	private static var dependencies: [TargetDependency] {
		[appKitModule.targetDependency]
	}

	/// All testable targets across all modules.
	static var testableTargets: [TestableTarget] {
		Modules.testableTargets
	}

	/// All source target references for code coverage (app + all modules).
	public static var codeCoverageTargets: [TargetReference] {
		[targetReference] + Modules.codeCoverageTargets
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
			targets: [appTarget, uiTestsTarget]
		)
	}
}

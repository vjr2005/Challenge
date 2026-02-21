import ProjectDescription

/// Factory for creating app schemes consistently.
public enum AppScheme {
	/// Creates a scheme for the given environment.
	/// - Parameters:
	///   - environment: The target environment.
	/// - Returns: A configured Scheme.
	static func create(
		environment: Environment
	) -> Scheme {
		let appTarget = App.targetReference

		return .scheme(
			name: environment.schemeName,
			buildAction: .buildAction(targets: [appTarget]),
			runAction: .runAction(
				configuration: environment.debugConfigurationName,
				executable: appTarget
			),
			archiveAction: .archiveAction(configuration: environment.releaseConfigurationName),
			profileAction: .profileAction(
				configuration: environment.releaseConfigurationName,
				executable: appTarget
			),
			analyzeAction: .analyzeAction(configuration: environment.debugConfigurationName)
		)
	}

	/// Creates the UI tests scheme.
	/// - Returns: A configured Scheme for UI tests.
	public static func uiTestsScheme() -> Scheme {
		let appTarget = App.targetReference

		return .scheme(
			name: "\(appName)UITests",
			buildAction: .buildAction(targets: [appTarget, App.uiTestsTargetReference]),
			testAction: .targets(
				[
					.testableTarget(
						target: App.uiTestsTargetReference
					),
				],
				options: .options(
					preferredScreenCaptureFormat: .screenRecording,
					coverage: true,
					codeCoverageTargets: [appTarget]
				)
			)
		)
	}

	/// Creates the module tests scheme using the test plan.
	/// - Returns: A configured Scheme for all module tests.
	public static func moduleTestsScheme() -> Scheme {
		.scheme(
			name: "\(appName)ModuleTests",
			buildAction: .buildAction(targets: [App.targetReference]),
			testAction: .testPlans(["Challenge.xctestplan"])
		)
	}

	/// Creates all app schemes for all environments.
	/// - Returns: Array of schemes for all environments.
	public static func allSchemes() -> [Scheme] {
		Environment.allCases.map { environment in
			create(environment: environment)
		}
	}
}

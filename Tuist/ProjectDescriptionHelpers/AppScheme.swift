import ProjectDescription

/// Factory for creating app schemes consistently.
public enum AppScheme {
	/// Creates a scheme for the given environment.
	/// - Parameters:
	///   - environment: The target environment.
	///   - includeTests: Whether to include test targets in the scheme.
	/// - Returns: A configured Scheme.
	static func create(
		environment: Environment,
		includeTests: Bool = false
	) -> Scheme {
		let appTarget = App.targetReference
		var testAction: TestAction?

		if includeTests {
			testAction = .targets(
				App.testableTargets,
				configuration: environment.debugConfigurationName,
				options: .options(
					coverage: true,
					codeCoverageTargets: App.codeCoverageTargets
				)
			)
		}

		return .scheme(
			name: environment.schemeName,
			buildAction: .buildAction(targets: [appTarget]),
			testAction: testAction,
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
					codeCoverageTargets: App.codeCoverageTargets
				)
			)
		)
	}

	/// Creates all app schemes for all environments.
	/// - Returns: Array of schemes for all environments.
	public static func allSchemes() -> [Scheme] {
		Environment.allCases.map { environment in
			create(
				environment: environment,
				includeTests: environment == .dev
			)
		}
	}
}

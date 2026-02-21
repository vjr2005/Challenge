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
				options: .options(coverage: true)
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
					coverage: true
				)
			)
		)
	}

	/// Creates the module tests scheme aggregating all module test targets.
	/// - Returns: A configured Scheme for all module tests.
	public static func moduleTestsScheme() -> Scheme {
		.scheme(
			name: "\(appName)ModuleTests",
			buildAction: .buildAction(targets: [App.targetReference]),
			testAction: .targets(
				App.testableTargets,
				options: .options(coverage: true)
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

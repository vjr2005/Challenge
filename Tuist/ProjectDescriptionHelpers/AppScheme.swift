import ProjectDescription

/// Factory for creating app schemes consistently.
public enum AppScheme {
	/// Creates a scheme for the given environment.
	/// - Parameters:
	///   - environment: The target environment.
	///   - testTargets: Test targets to include (only for Dev environment by default).
	/// - Returns: A configured Scheme.
	public static func create(
		environment: Environment,
		testTargets: [TestableTarget] = []
	) -> Scheme {
		var testAction: TestAction?

		if !testTargets.isEmpty {
			testAction = .targets(
				testTargets,
				configuration: environment.debugConfigurationName,
				options: .options(coverage: true)
			)
		}

		return .scheme(
			name: environment.schemeName,
			buildAction: .buildAction(targets: [.target(appName)]),
			testAction: testAction,
			runAction: .runAction(
				configuration: environment.debugConfigurationName,
				executable: .target(appName)
			),
			archiveAction: .archiveAction(configuration: environment.releaseConfigurationName),
			profileAction: .profileAction(
				configuration: environment.releaseConfigurationName,
				executable: .target(appName)
			),
			analyzeAction: .analyzeAction(configuration: environment.debugConfigurationName)
		)
	}

	/// Creates all app schemes for all environments.
	/// - Parameters:
	///   - testTargets: Test targets to include in the Dev scheme.
	/// - Returns: Array of schemes for all environments.
	public static func allSchemes(testTargets: [TestableTarget] = []) -> [Scheme] {
		Environment.allCases.map { environment in
			create(
				environment: environment,
				testTargets: environment == .dev ? testTargets : []
			)
		}
	}
}

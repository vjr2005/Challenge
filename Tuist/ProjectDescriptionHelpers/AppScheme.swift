import ProjectDescription

/// Factory for creating app schemes consistently.
public enum AppScheme {
	/// Creates a scheme for the given environment.
	/// - Parameters:
	///   - environment: The target environment.
	///   - includeTests: Whether to include test targets in the scheme.
	/// - Returns: A configured Scheme.
	public static func create(
		environment: Environment,
		includeTests: Bool = false
	) -> Scheme {
		var testAction: TestAction?

		if includeTests {
			let testTargetNames = [
				// Unit Tests
				"\(appName)AppKitTests",
				"\(appName)CoreTests",
				"\(appName)NetworkingTests",
				"\(appName)DesignSystemTests",
				"\(appName)CharacterTests",
				"\(appName)HomeTests",
				"\(appName)SystemTests",
				// Snapshot Tests
				"\(appName)AppKitSnapshotTests",
				"\(appName)DesignSystemSnapshotTests",
				"\(appName)CharacterSnapshotTests",
				"\(appName)HomeSnapshotTests",
				"\(appName)SystemSnapshotTests",
			]

			let testableTargets = testTargetNames.map { name in
				TestableTarget.testableTarget(
					target: .target(name),
					parallelization: .swiftTestingOnly
				)
			}

			testAction = .targets(
				testableTargets,
				configuration: environment.debugConfigurationName,
				options: .options(
					coverage: true,
					codeCoverageTargets: Modules.codeCoverageTargets
				)
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

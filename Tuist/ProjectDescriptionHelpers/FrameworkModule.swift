import ProjectDescription

/// A module containing targets and schemes for a framework.
public struct FrameworkModule {
	public let targets: [Target]
	public let schemes: [Scheme]

	/// Creates a framework module with targets (framework, mocks, tests) and scheme with coverage.
	/// - Parameters:
	///   - name: The framework name (e.g., "Networking", "Features/Home")
	///   - destinations: Deployment destinations (default: iPhone, iPad)
	///   - dependencies: Framework dependencies
	///   - testDependencies: Additional test-only dependencies
	public static func create(
		name: String,
		destinations: ProjectDescription.Destinations = [.iPhone, .iPad],
		dependencies: [TargetDependency] = [],
		testDependencies: [TargetDependency] = [],
	) -> FrameworkModule {
		let targetName = "\(appName)\(name)"
		let testsTargetName = "\(targetName)Tests"

		let framework = Target.target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)",
			sources: ["Libraries/\(name)/Sources/**"],
			dependencies: dependencies,
		)

		let mocks = Target.target(
			name: "\(targetName)Mocks",
			destinations: destinations,
			product: .framework,
			bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)Mocks",
			sources: ["Libraries/\(name)/Mocks/**"],
			dependencies: [.target(name: targetName)],
		)

		let tests = Target.target(
			name: testsTargetName,
			destinations: destinations,
			product: .unitTests,
			bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(testsTargetName)",
			sources: ["Libraries/\(name)/Tests/**"],
			dependencies: [
				.target(name: targetName),
				.target(name: "\(targetName)Mocks"),
			] + testDependencies,
		)

		let testableTarget: TestableTarget = "\(testsTargetName)"

		let scheme = Scheme.scheme(
			name: targetName,
			buildAction: .buildAction(targets: [.target(targetName)]),
			testAction: .targets(
				[testableTarget],
				options: .options(coverage: true)
			)
		)

		return FrameworkModule(
			targets: [framework, mocks, tests],
			schemes: [scheme],
		)
	}
}

import Foundation
import ProjectDescription

/// A module containing targets and schemes for a framework.
public struct FrameworkModule {
	public let targets: [Target]
	public let schemes: [Scheme]

	/// Creates a framework module with targets (framework, mocks, tests) and scheme with coverage.
	/// - Parameters:
	///   - name: The framework name (e.g., "Networking", "Character"). Must not contain "/".
	///   - path: The path to the module sources relative to Libraries/ (e.g., "Features/Character").
	///           Defaults to name if not specified.
	///   - destinations: Deployment destinations (default: iPhone, iPad)
	///   - dependencies: Framework dependencies
	///   - testDependencies: Additional test-only dependencies
	///   - hasMocks: Whether to create a public Mocks framework (default: true).
	///               Set to false for modules with only internal mocks in Tests/Mocks/.
	public static func create(
		name: String,
		path: String? = nil,
		destinations: ProjectDescription.Destinations = [.iPhone, .iPad],
		dependencies: [TargetDependency] = [],
		testDependencies: [TargetDependency] = [],
		hasMocks: Bool = true,
	) -> FrameworkModule {
		let targetName = "\(appName)\(name)"
		let testsTargetName = "\(targetName)Tests"
		let sourcesPath = path ?? name

		let framework = Target.target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)",
			sources: ["Libraries/\(sourcesPath)/Sources/**"],
			dependencies: dependencies,
		)

		var targets = [framework]
		var testsDependencies: [TargetDependency] = [.target(name: targetName)]

		if hasMocks {
			let mocks = Target.target(
				name: "\(targetName)Mocks",
				destinations: destinations,
				product: .framework,
				bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)Mocks",
				sources: ["Libraries/\(sourcesPath)/Mocks/**"],
				dependencies: [.target(name: targetName)],
			)
			targets.append(mocks)
			testsDependencies.append(.target(name: "\(targetName)Mocks"))
		}

		let tests = Target.target(
			name: testsTargetName,
			destinations: destinations,
			product: .unitTests,
			bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(testsTargetName)",
			sources: ["Libraries/\(sourcesPath)/Tests/**"],
			dependencies: testsDependencies + testDependencies,
		)
		targets.append(tests)

		let testableTarget: TestableTarget = "\(testsTargetName)"

		let scheme = Scheme.scheme(
			name: targetName,
			buildAction: .buildAction(targets: [.target(targetName), .target(testsTargetName)]),
			testAction: .targets(
				[testableTarget],
				options: .options(coverage: true)
			)
		)

		return FrameworkModule(
			targets: targets,
			schemes: [scheme],
		)
	}
}

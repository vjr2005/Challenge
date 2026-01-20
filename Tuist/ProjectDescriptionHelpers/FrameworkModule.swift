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
	///   - hasTests: Whether to create a Tests target (default: true).
	///               Set to false for simple configuration modules without tests.
	public static func create(
		name: String,
		path: String? = nil,
		destinations: ProjectDescription.Destinations = [.iPhone, .iPad],
		dependencies: [TargetDependency] = [],
		testDependencies: [TargetDependency] = [],
		hasMocks: Bool = true,
		hasTests: Bool = true,
		hasResources: Bool = false
	) -> FrameworkModule {
		let targetName = "\(appName)\(name)"
		let testsTargetName = "\(targetName)Tests"
		let sourcesPath = path ?? name

		let resources: ResourceFileElements? = hasResources ? [
			.glob(pattern: "Libraries/\(sourcesPath)/Sources/Resources/**", excluding: [])
		] : nil

		let framework = Target.target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)",
			deploymentTargets: developmentTarget,
			sources: ["Libraries/\(sourcesPath)/Sources/**"],
			resources: resources,
			scripts: [SwiftLint.script(path: "Libraries/\(sourcesPath)/Sources")],
			dependencies: dependencies
		)

		var targets = [framework]
		var testsDependencies: [TargetDependency] = [.target(name: targetName)]

		if hasMocks {
			let mocks = Target.target(
				name: "\(targetName)Mocks",
				destinations: destinations,
				product: .framework,
				bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)Mocks",
				deploymentTargets: developmentTarget,
				sources: ["Libraries/\(sourcesPath)/Mocks/**"],
				dependencies: [.target(name: targetName)]
			)
			targets.append(mocks)
			testsDependencies.append(.target(name: "\(targetName)Mocks"))
		}

		var scheme: Scheme

		if hasTests {
			let tests = Target.target(
				name: testsTargetName,
				destinations: destinations,
				product: .unitTests,
				bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(testsTargetName)",
				deploymentTargets: developmentTarget,
				sources: ["Libraries/\(sourcesPath)/Tests/**"],
				resources: [
					.glob(pattern: "Libraries/\(sourcesPath)/Tests/Resources/**", excluding: []),
					.glob(pattern: "Libraries/\(sourcesPath)/Tests/Fixtures/**", excluding: []),
				],
				dependencies: testsDependencies + testDependencies
			)
			targets.append(tests)

			let testableTarget: TestableTarget = "\(testsTargetName)"

			scheme = Scheme.scheme(
				name: targetName,
				buildAction: .buildAction(targets: [.target(targetName), .target(testsTargetName)]),
				testAction: .targets(
					[testableTarget],
					options: .options(coverage: true)
				)
			)
		} else {
			scheme = Scheme.scheme(
				name: targetName,
				buildAction: .buildAction(targets: [.target(targetName)])
			)
		}

		return FrameworkModule(
			targets: targets,
			schemes: [scheme],
		)
	}
}

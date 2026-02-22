import Foundation
import ProjectDescription

/// A module containing targets and schemes for a framework.
public struct Module: @unchecked Sendable {
	let directory: String
	let name: String
	let hasMocks: Bool
	let hasUnitTests: Bool
	let hasSnapshotTests: Bool
	let includeInCoverage: Bool
	let targets: [Target]
	let schemes: [Scheme]

	// MARK: - Computed Properties

	/// Cross-project target dependency for build dependencies.
	var targetDependency: TargetDependency {
		.project(target: name, path: .relativeToRoot(directory))
	}

	/// Cross-project testable targets for workspace-level test plans.
	var testableTargets: [TestableTarget] {
		var targets: [TestableTarget] = []
		if hasUnitTests {
			targets.append(
				.testableTarget(
					target: .project(path: .relativeToRoot(directory), target: "\(name)Tests"),
					parallelization: .swiftTestingOnly
				)
			)
		}
		if hasSnapshotTests {
			targets.append(
				.testableTarget(
					target: .project(path: .relativeToRoot(directory), target: "\(name)SnapshotTests"),
					parallelization: .swiftTestingOnly
				)
			)
		}
		return targets
	}

	/// Cross-project mocks dependency for build dependencies.
	var mocksTargetDependency: TargetDependency {
		.project(target: name.appending("Mocks"), path: .relativeToRoot(directory))
	}

	/// Cross-project target reference for code coverage.
	var codeCoverageTargetReference: TargetReference {
		.project(path: .relativeToRoot(directory), target: name)
	}

	// MARK: - Private Helpers

	/// Checks if a folder contains any files (searches recursively).
	/// - Parameters:
	///   - path: The absolute path to the folder
	///   - extension: Optional file extension to filter by (e.g., ".swift"). If nil, matches any file.
	/// - Returns: true if the folder contains at least one matching file
	private static func folderContainsFiles(at path: String, withExtension ext: String? = nil) -> Bool {
		let fileManager = FileManager.default

		guard let enumerator = fileManager.enumerator(atPath: path) else {
			return false
		}

		while let file = enumerator.nextObject() as? String {
			if let ext {
				if file.hasSuffix(ext) {
					return true
				}
			} else {
				// Check it's a file, not a directory
				var isDirectory: ObjCBool = false
				let fullPath = "\(path)/\(file)"
				if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory), !isDirectory.boolValue {
					return true
				}
			}
		}

		return false
	}

	/// Checks if a Mocks folder exists with Swift files.
	private static func hasMocksFolder(directory: String) -> Bool {
		folderContainsFiles(at: "\(workspaceRoot)/\(directory)/Mocks", withExtension: ".swift")
	}

	/// Checks if a Tests/Unit folder exists with Swift files.
	private static func hasUnitTestsFolder(directory: String) -> Bool {
		folderContainsFiles(at: "\(workspaceRoot)/\(directory)/Tests/Unit", withExtension: ".swift")
	}

	/// Checks if a Tests/Snapshots folder exists with Swift files.
	private static func hasSnapshotTestsFolder(directory: String) -> Bool {
		folderContainsFiles(at: "\(workspaceRoot)/\(directory)/Tests/Snapshots", withExtension: ".swift")
	}

	/// Checks if a Tests/Shared folder exists with Swift files.
	private static func hasSharedTestsFolder(directory: String) -> Bool {
		folderContainsFiles(at: "\(workspaceRoot)/\(directory)/Tests/Shared", withExtension: ".swift")
	}

	/// Checks if a Sources/Resources folder exists with any files.
	private static func hasResourcesFolder(directory: String) -> Bool {
		folderContainsFiles(at: "\(workspaceRoot)/\(directory)/Sources/Resources")
	}

	// MARK: - Factory

	/// Creates a framework module with targets (framework, mocks, tests, snapshot tests) and scheme with coverage.
	///
	/// Each module becomes an independent Tuist project with its own `Project.swift`.
	/// Source/test paths are relative to the module directory. Folder existence checks use the full workspace-root path.
	///
	/// - Parameters:
	///   - directory: The module's directory relative to the workspace root (e.g., "Libraries/Core", "Features/Character", "AppKit").
	///                The last path component is used as the module name (e.g., "Core" → target `ChallengeCore`).
	///   - destinations: Deployment destinations (default: iPhone, iPad)
	///   - dependencies: Framework dependencies
	///   - testDependencies: Additional test-only dependencies
	///   - snapshotTestDependencies: Additional snapshot test-only dependencies (SnapshotTesting is added automatically)
	///   - includeInCoverage: Whether the module's source target should be included in workspace-level code coverage.
	///                        Defaults to `true`. Set to `false` for infrastructure modules without meaningful source (e.g., Resources, SnapshotTestKit).
	///   - targetSettingsOverrides: Additional per-target build settings merged on top of `projectBaseSettings`.
	///                              Use to override specific keys (e.g., `SWIFT_DEFAULT_ACTOR_ISOLATION` for nonisolated modules).
	/// - Note: Mocks and test targets are automatically created if the corresponding folders exist.
	///         Test structure: Tests/Unit/, Tests/Snapshots/, Tests/Shared/ (Stubs, Fixtures, Resources).
	static func create(
		directory: String,
		destinations: ProjectDescription.Destinations = [.iPhone, .iPad],
		dependencies: [TargetDependency] = [],
		testDependencies: [TargetDependency] = [],
		snapshotTestDependencies: [TargetDependency] = [],
		includeInCoverage: Bool = true,
		targetSettingsOverrides: SettingsDictionary = [:]
	) -> Module {
		let components = directory.split(separator: "/")
		guard let last = components.last else {
			fatalError("Module directory must not be empty")
		}
		let shortName = String(last)
		let targetName = "\(appName)\(shortName)"
		let testsTargetName = "\(targetName)Tests"
		let settings: Settings = .settings(base: projectBaseSettings.merging(targetSettingsOverrides) { _, new in new })

		let depth = components.count
		let workspaceRoot = (0..<depth).map { _ in ".." }.joined(separator: "/")

		let resources: ResourceFileElements? = hasResourcesFolder(directory: directory) ? [
			.glob(pattern: "Sources/Resources/**", excluding: [])
		] : nil

		let framework = Target.target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)",
			deploymentTargets: developmentTarget,
			sources: ["Sources/**"],
			resources: resources,
			scripts: [SwiftLint.script(path: "Sources", workspaceRoot: workspaceRoot)],
			dependencies: dependencies,
			settings: settings
		)

		var targets = [framework]
		var testsDependencies: [TargetDependency] = [.target(name: targetName)]

		let moduleHasMocks = hasMocksFolder(directory: directory)
		if moduleHasMocks {
			let mocks = Target.target(
				name: "\(targetName)Mocks",
				destinations: destinations,
				product: .framework,
				bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)Mocks",
				deploymentTargets: developmentTarget,
				sources: ["Mocks/**"],
				dependencies: [.target(name: targetName)],
				settings: settings
			)
			targets.append(mocks)
			testsDependencies.append(.target(name: "\(targetName)Mocks"))
		}

		var scheme: Scheme
		var testableTargets: [TestableTarget] = []
		var buildTargets: [TargetReference] = [.target(targetName)]

		let hasShared = hasSharedTestsFolder(directory: directory)

		let moduleHasUnitTests = hasUnitTestsFolder(directory: directory)
		// Unit Tests target (Tests/Unit/ + Tests/Shared/)
		if moduleHasUnitTests {
			let unitSources: SourceFilesList = hasShared
				? ["Tests/Unit/**", "Tests/Shared/**"]
				: ["Tests/Unit/**"]

			let unitResources: ResourceFileElements = hasShared ? [
				.glob(pattern: "Tests/Shared/Resources/**", excluding: []),
				.glob(pattern: "Tests/Shared/Fixtures/**", excluding: []),
			] : []

			let tests = Target.target(
				name: testsTargetName,
				destinations: destinations,
				product: .unitTests,
				bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(testsTargetName)",
				deploymentTargets: developmentTarget,
				sources: unitSources,
				resources: unitResources,
				dependencies: testsDependencies + testDependencies,
				settings: settings
			)
			targets.append(tests)
			testableTargets.append(
				.testableTarget(
					target: .target(testsTargetName),
					parallelization: .swiftTestingOnly
				)
			)
			buildTargets.append(.target(testsTargetName))
		}

		// Snapshot Tests target (Tests/Snapshots/ + Tests/Shared/)
		let snapshotTestsTargetName = "\(targetName)SnapshotTests"
		let moduleHasSnapshotTests = hasSnapshotTestsFolder(directory: directory)
		if moduleHasSnapshotTests {
			let snapshotSources: SourceFilesList = hasShared
				? ["Tests/Snapshots/**", "Tests/Shared/**"]
				: ["Tests/Snapshots/**"]

			let snapshotResources: ResourceFileElements = hasShared ? [
				.glob(pattern: "Tests/Shared/Resources/**", excluding: []),
			] : []

			let snapshotTests = Target.target(
				name: snapshotTestsTargetName,
				destinations: destinations,
				product: .unitTests,
				bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(snapshotTestsTargetName)",
				deploymentTargets: developmentTarget,
				sources: snapshotSources,
				resources: snapshotResources,
				dependencies: testsDependencies + [snapshotTestKitModule.targetDependency] + snapshotTestDependencies,
				settings: settings
			)
			targets.append(snapshotTests)
			testableTargets.append(
				.testableTarget(
					target: .target(snapshotTestsTargetName),
					parallelization: .swiftTestingOnly
				)
			)
			buildTargets.append(.target(snapshotTestsTargetName))
		}

		if !testableTargets.isEmpty {
			scheme = Scheme.scheme(
				name: targetName,
				buildAction: .buildAction(targets: buildTargets),
				testAction: .targets(
					testableTargets,
					options: .options(
						coverage: true,
						codeCoverageTargets: [.target(targetName)]
					)
				)
			)
		} else {
			scheme = Scheme.scheme(
				name: targetName,
				buildAction: .buildAction(targets: [.target(targetName)])
			)
		}

		return Module(
			directory: directory,
			name: targetName,
			hasMocks: moduleHasMocks,
			hasUnitTests: moduleHasUnitTests,
			hasSnapshotTests: moduleHasSnapshotTests,
			includeInCoverage: includeInCoverage,
			targets: targets,
			schemes: [scheme],
		)
	}

	// MARK: - Project

	/// Generates an independent Tuist project for this module.
	public var project: Project {
		Project(
			name: name,
			options: .options(
				automaticSchemesOptions: .disabled,
				disableBundleAccessors: true,
				disableSynthesizedResourceAccessors: true
			),
			settings: .settings(
				base: projectBaseSettings,
				configurations: BuildConfiguration.all
			),
			targets: targets,
			schemes: schemes
		)
	}
}

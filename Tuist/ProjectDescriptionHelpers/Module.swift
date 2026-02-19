import Foundation
import ProjectDescription

/// A module containing targets and schemes for a framework.
public struct Module: @unchecked Sendable {
	public let directory: String
	public let name: String
	public let hasMocks: Bool
	public let hasUnitTests: Bool
	public let hasSnapshotTests: Bool
	public let targets: [Target]
	public let schemes: [Scheme]

	// MARK: - Computed Properties

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

	public var path: ProjectDescription.Path {
		.path("\(workspaceRoot)/\(directory)")
	}

	public var targetReference: TargetReference {
		.project(path: path, target: name)
	}

	public var targetDependency: TargetDependency {
		.project(target: name, path: path)
	}

	public var testableTargets: [TestableTarget] {
		var targets: [TestableTarget] = []
		if hasUnitTests {
			targets.append(
				.testableTarget(
					target: .project(path: path, target: "\(name)Tests"),
					parallelization: .swiftTestingOnly
				)
			)
		}
		if hasSnapshotTests {
			targets.append(
				.testableTarget(
					target: .project(path: path, target: "\(name)SnapshotTests"),
					parallelization: .swiftTestingOnly
				)
			)
		}
		return targets
	}

	public var mocksTargetDependency: TargetDependency {
		.project(target: name.appending("Mocks"), path: path)
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
	/// Each module has its own `Project.swift`, so target paths are relative to the module directory.
	/// Folder existence checks use the full path from the workspace root.
	///
	/// - Parameters:
	///   - directory: The module's directory relative to the workspace root (e.g., "Libraries/Core", "Features/Character", "AppKit").
	///                The last path component is used as the module name (e.g., "Core" → target `ChallengeCore`).
	///   - destinations: Deployment destinations (default: iPhone, iPad)
	///   - dependencies: Framework dependencies
	///   - testDependencies: Additional test-only dependencies
	///   - snapshotTestDependencies: Additional snapshot test-only dependencies (SnapshotTesting is added automatically)
	///   - targetSettingsOverrides: Additional per-target build settings merged on top of `projectBaseSettings`.
	///                              Use to override specific keys (e.g., `SWIFT_DEFAULT_ACTOR_ISOLATION` for nonisolated modules).
	/// - Note: Mocks and test targets are automatically created if the corresponding folders exist.
	///         Test structure: Tests/Unit/, Tests/Snapshots/, Tests/Shared/ (Stubs, Fixtures, Resources).
	public static func create(
		directory: String,
		destinations: ProjectDescription.Destinations = [.iPhone, .iPad],
		dependencies: [TargetDependency] = [],
		testDependencies: [TargetDependency] = [],
		snapshotTestDependencies: [TargetDependency] = [],
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

		let resources: ResourceFileElements? = hasResourcesFolder(directory: directory) ? [
			.glob(pattern: "Sources/Resources/**", excluding: [])
		] : nil

		let relativeWorkspaceRoot: String = {
			let depth = components.count
			return depth > 0 ? Array(repeating: "..", count: depth).joined(separator: "/") : "."
		}()

		let framework = Target.target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)",
			deploymentTargets: developmentTarget,
			sources: ["Sources/**"],
			resources: resources,
			scripts: [SwiftLint.script(path: "Sources", workspaceRoot: relativeWorkspaceRoot)],
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
			targets: targets,
			schemes: [scheme],
		)
	}
}

import Foundation
import ProjectDescription

/// A module representing an SPM local package with Tuist-managed test targets.
///
/// Source and mocks targets are defined in each module's `Package.swift` and resolved
/// through `Tuist/Package.swift` as `.framework` products. Test targets live in the
/// root project and depend on the package frameworks via `.external(name:)`.
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

	/// Target dependency for consuming targets.
	var targetDependency: TargetDependency {
		.external(name: name)
	}

	/// Mocks dependency for consuming targets.
	var mocksTargetDependency: TargetDependency {
		.external(name: "\(name)Mocks")
	}

	/// Testable targets for scheme configuration.
	var testableTargets: [TestableTarget] {
		var result: [TestableTarget] = []
		if hasUnitTests {
			result.append(
				.testableTarget(
					target: .target("\(name)Tests"),
					parallelization: .swiftTestingOnly
				)
			)
		}
		if hasSnapshotTests {
			result.append(
				.testableTarget(
					target: .target("\(name)SnapshotTests"),
					parallelization: .swiftTestingOnly
				)
			)
		}
		return result
	}

	// MARK: - Private Helpers

	/// Checks if a folder contains any files (searches recursively).
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

	// MARK: - Factory

	/// Creates a module with test targets that depend on SPM package frameworks.
	///
	/// Source and mocks are SPM products (resolved as `.framework` via `Tuist/Package.swift`).
	/// Test targets are Tuist-managed in the root project, depending on `.external()` packages.
	///
	/// - Parameters:
	///   - directory: The module's directory relative to the workspace root (e.g., "Libraries/Core", "Features/Character", "AppKit").
	///                The last path component is used as the module name (e.g., "Core" → target `ChallengeCore`).
	///   - testDependencies: Additional test-only dependencies (e.g., mock packages from other modules).
	///   - snapshotTestDependencies: Additional snapshot test-only dependencies.
	///   - includeInCoverage: Whether the module should be included in code coverage. Defaults to `true`.
	///   - testTargetSettingsOverrides: Additional build settings for test targets (e.g., nonisolated modules).
	static func create(
		directory: String,
		testDependencies: [TargetDependency] = [],
		snapshotTestDependencies: [TargetDependency] = [],
		includeInCoverage: Bool = true,
		testTargetSettingsOverrides: SettingsDictionary = [:]
	) -> Module {
		let components = directory.split(separator: "/")
		guard let last = components.last else {
			fatalError("Module directory must not be empty")
		}
		let shortName = String(last)
		let targetName = "\(appName)\(shortName)"
		let testsTargetName = "\(targetName)Tests"
		let settings: Settings = .settings(base: projectBaseSettings.merging(testTargetSettingsOverrides) { _, new in new })

		// Paths relative to workspace root (test targets live in root project)
		let pathPrefix = "\(directory)/"

		var targets: [Target] = []
		var testsDependencies: [TargetDependency] = [.external(name: targetName)]

		let moduleHasMocks = hasMocksFolder(directory: directory)
		if moduleHasMocks {
			testsDependencies.append(.external(name: "\(targetName)Mocks"))
		}

		let hasShared = hasSharedTestsFolder(directory: directory)
		var testableTargets: [TestableTarget] = []
		var buildTargets: [TargetReference] = []

		// Unit Tests target (Tests/Unit/ + Tests/Shared/)
		let moduleHasUnitTests = hasUnitTestsFolder(directory: directory)
		if moduleHasUnitTests {
			let unitSources: SourceFilesList = hasShared
				? ["\(pathPrefix)Tests/Unit/**", "\(pathPrefix)Tests/Shared/**"]
				: ["\(pathPrefix)Tests/Unit/**"]

			let unitResources: ResourceFileElements = hasShared ? [
				.glob(pattern: "\(pathPrefix)Tests/Shared/Resources/**", excluding: []),
				.glob(pattern: "\(pathPrefix)Tests/Shared/Fixtures/**", excluding: []),
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
				? ["\(pathPrefix)Tests/Snapshots/**", "\(pathPrefix)Tests/Shared/**"]
				: ["\(pathPrefix)Tests/Snapshots/**"]

			let snapshotResources: ResourceFileElements = hasShared ? [
				.glob(pattern: "\(pathPrefix)Tests/Shared/Resources/**", excluding: []),
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

		// Per-module test scheme
		var scheme: Scheme
		if !testableTargets.isEmpty {
			scheme = .scheme(
				name: targetName,
				buildAction: .buildAction(targets: buildTargets),
				testAction: .targets(
					testableTargets,
					options: .options(coverage: true)
				)
			)
		} else {
			scheme = .scheme(
				name: targetName,
				buildAction: .buildAction(targets: [])
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
			schemes: [scheme]
		)
	}
}

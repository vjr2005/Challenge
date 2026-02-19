import Foundation
import ProjectDescription

/// A module containing targets and schemes for a framework.
public struct FrameworkModule: @unchecked Sendable {
	public let baseFolder: String
	public let name: String
	public let targets: [Target]
	public let schemes: [Scheme]

	/// Returns the project root directory (parent of Tuist/).
	private static var projectRoot: String {
		let filePath = #file
		// #file returns: .../Tuist/ProjectDescriptionHelpers/FrameworkModule.swift
		// We need to go up 3 levels to get to project root
		let url = URL(fileURLWithPath: filePath)
			.deletingLastPathComponent() // Remove FrameworkModule.swift
			.deletingLastPathComponent() // Remove ProjectDescriptionHelpers
			.deletingLastPathComponent() // Remove Tuist
		return url.path
	}

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
	private static func hasMocksFolder(baseFolder: String, path: String) -> Bool {
		folderContainsFiles(at: "\(projectRoot)/\(baseFolder)/\(path)/Mocks", withExtension: ".swift")
	}

	/// Checks if a Tests/Unit folder exists with Swift files.
	private static func hasUnitTestsFolder(baseFolder: String, path: String) -> Bool {
		folderContainsFiles(at: "\(projectRoot)/\(baseFolder)/\(path)/Tests/Unit", withExtension: ".swift")
	}

	/// Checks if a Tests/Snapshots folder exists with Swift files.
	private static func hasSnapshotTestsFolder(baseFolder: String, path: String) -> Bool {
		folderContainsFiles(at: "\(projectRoot)/\(baseFolder)/\(path)/Tests/Snapshots", withExtension: ".swift")
	}

	/// Checks if a Tests/Shared folder exists with Swift files.
	private static func hasSharedTestsFolder(baseFolder: String, path: String) -> Bool {
		folderContainsFiles(at: "\(projectRoot)/\(baseFolder)/\(path)/Tests/Shared", withExtension: ".swift")
	}

	/// Checks if a Sources/Resources folder exists with any files.
	private static func hasResourcesFolder(baseFolder: String, path: String) -> Bool {
		folderContainsFiles(at: "\(projectRoot)/\(baseFolder)/\(path)/Sources/Resources")
	}

	/// Builds a path for target source/resource globs.
	/// When prefix is empty (standalone mode), returns the suffix directly.
	private static func targetPath(_ prefix: String, _ suffix: String) -> String {
		prefix.isEmpty ? suffix : "\(prefix)/\(suffix)"
	}

	/// Creates a framework module with targets (framework, mocks, tests, snapshot tests) and scheme with coverage.
	/// - Parameters:
	///   - name: The framework name (e.g., "Networking", "Character"). Must not contain "/".
	///   - baseFolder: The base folder containing the module (e.g., "Libraries" or "Features").
	///                 Defaults to "Libraries".
	///   - path: The path to the module sources relative to baseFolder (e.g., "Character").
	///           Defaults to name if not specified.
	///   - standalone: When true, target paths are relative to the module directory (for modules with their own Project.swift).
	///                 Folder existence checks still use the full path from the workspace root.
	///   - destinations: Deployment destinations (default: iPhone, iPad)
	///   - dependencies: Framework dependencies
	///   - testDependencies: Additional test-only dependencies
	///   - snapshotTestDependencies: Additional snapshot test-only dependencies (SnapshotTesting is added automatically)
	///   - settings: Optional per-target build settings override (applied to framework, mocks, and test targets)
	/// - Note: Mocks and test targets are automatically created if the corresponding folders exist.
	///         Test structure: Tests/Unit/, Tests/Snapshots/, Tests/Shared/ (Stubs, Fixtures, Resources).
	public static func create(
		name: String,
		baseFolder: String = "Libraries",
		path: String? = nil,
		standalone: Bool = false,
		destinations: ProjectDescription.Destinations = [.iPhone, .iPad],
		dependencies: [TargetDependency] = [],
		testDependencies: [TargetDependency] = [],
		snapshotTestDependencies: [TargetDependency] = [],
		settings: Settings? = nil
	) -> FrameworkModule {
		let targetName = "\(appName)\(name)"
		let testsTargetName = "\(targetName)Tests"
		let sourcesPath = path ?? name
		let fullPath = "\(baseFolder)/\(sourcesPath)"
		let targetPrefix = standalone ? "" : fullPath

		let resources: ResourceFileElements? = hasResourcesFolder(baseFolder: baseFolder, path: sourcesPath) ? [
			.glob(pattern: "\(targetPath(targetPrefix, "Sources/Resources/**"))", excluding: [])
		] : nil

		let workspaceRoot: String = {
			guard standalone else { return "." }
			let depth = [baseFolder, sourcesPath]
				.filter { !$0.isEmpty && $0 != "." }
				.count
			return depth > 0 ? Array(repeating: "..", count: depth).joined(separator: "/") : "."
		}()

		let framework = Target.target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)",
			deploymentTargets: developmentTarget,
			sources: ["\(targetPath(targetPrefix, "Sources/**"))"],
			resources: resources,
			scripts: [SwiftLint.script(path: targetPath(targetPrefix, "Sources"), workspaceRoot: workspaceRoot)],
			dependencies: dependencies,
			settings: settings
		)

		var targets = [framework]
		var testsDependencies: [TargetDependency] = [.target(name: targetName)]

		if hasMocksFolder(baseFolder: baseFolder, path: sourcesPath) {
			let mocks = Target.target(
				name: "\(targetName)Mocks",
				destinations: destinations,
				product: .framework,
				bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(targetName)Mocks",
				deploymentTargets: developmentTarget,
				sources: ["\(targetPath(targetPrefix, "Mocks/**"))"],
				dependencies: [.target(name: targetName)],
				settings: settings
			)
			targets.append(mocks)
			testsDependencies.append(.target(name: "\(targetName)Mocks"))
		}

		var scheme: Scheme
		var testableTargets: [TestableTarget] = []
		var buildTargets: [TargetReference] = [.target(targetName)]

		let hasShared = hasSharedTestsFolder(baseFolder: baseFolder, path: sourcesPath)

		// Unit Tests target (Tests/Unit/ + Tests/Shared/)
		if hasUnitTestsFolder(baseFolder: baseFolder, path: sourcesPath) {
			let unitSources: SourceFilesList = hasShared
				? ["\(targetPath(targetPrefix, "Tests/Unit/**"))", "\(targetPath(targetPrefix, "Tests/Shared/**"))"]
				: ["\(targetPath(targetPrefix, "Tests/Unit/**"))"]

			let unitResources: ResourceFileElements = hasShared ? [
				.glob(pattern: "\(targetPath(targetPrefix, "Tests/Shared/Resources/**"))", excluding: []),
				.glob(pattern: "\(targetPath(targetPrefix, "Tests/Shared/Fixtures/**"))", excluding: []),
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
		if hasSnapshotTestsFolder(baseFolder: baseFolder, path: sourcesPath) {
			let snapshotSources: SourceFilesList = hasShared
				? ["\(targetPath(targetPrefix, "Tests/Snapshots/**"))", "\(targetPath(targetPrefix, "Tests/Shared/**"))"]
				: ["\(targetPath(targetPrefix, "Tests/Snapshots/**"))"]

			let snapshotResources: ResourceFileElements = hasShared ? [
				.glob(pattern: "\(targetPath(targetPrefix, "Tests/Shared/Resources/**"))", excluding: []),
			] : []

			let snapshotTests = Target.target(
				name: snapshotTestsTargetName,
				destinations: destinations,
				product: .unitTests,
				bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}.\(snapshotTestsTargetName)",
				deploymentTargets: developmentTarget,
				sources: snapshotSources,
				resources: snapshotResources,
				dependencies: testsDependencies + [.target(name: "\(appName)SnapshotTestKit")] + snapshotTestDependencies,
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

		return FrameworkModule(
			baseFolder: baseFolder,
			name: targetName,
			targets: targets,
			schemes: [scheme],
		)
	}
}

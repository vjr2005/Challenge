import Foundation
import ProjectDescription

/// A module containing targets and schemes for a framework.
public struct FrameworkModule: @unchecked Sendable {
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
	private static func hasMocksFolder(path: String) -> Bool {
		folderContainsFiles(at: "\(projectRoot)/Libraries/\(path)/Mocks", withExtension: ".swift")
	}

	/// Checks if a Tests folder exists with Swift files.
	private static func hasTestsFolder(path: String) -> Bool {
		folderContainsFiles(at: "\(projectRoot)/Libraries/\(path)/Tests", withExtension: ".swift")
	}

	/// Checks if a Sources/Resources folder exists with any files.
	private static func hasResourcesFolder(path: String) -> Bool {
		folderContainsFiles(at: "\(projectRoot)/Libraries/\(path)/Sources/Resources")
	}

	/// Creates a framework module with targets (framework, mocks, tests) and scheme with coverage.
	/// - Parameters:
	///   - name: The framework name (e.g., "Networking", "Character"). Must not contain "/".
	///   - path: The path to the module sources relative to Libraries/ (e.g., "Features/Character").
	///           Defaults to name if not specified.
	///   - destinations: Deployment destinations (default: iPhone, iPad)
	///   - dependencies: Framework dependencies
	///   - testDependencies: Additional test-only dependencies
	/// - Note: Mocks, Tests, and Resources targets are automatically created if the corresponding
	///         folders exist with appropriate files (Swift files for Mocks/Tests, any files for Resources).
	public static func create(
		name: String,
		path: String? = nil,
		destinations: ProjectDescription.Destinations = [.iPhone, .iPad],
		dependencies: [TargetDependency] = [],
		testDependencies: [TargetDependency] = []
	) -> FrameworkModule {
		let targetName = "\(appName)\(name)"
		let testsTargetName = "\(targetName)Tests"
		let sourcesPath = path ?? name

		let resources: ResourceFileElements? = hasResourcesFolder(path: sourcesPath) ? [
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

		if hasMocksFolder(path: sourcesPath) {
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

		if hasTestsFolder(path: sourcesPath) {
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
			targets: targets,
			schemes: [scheme],
		)
	}
}

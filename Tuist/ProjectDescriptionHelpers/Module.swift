import Foundation
import ProjectDescription

/// A module representing an SPM local package.
public struct Module: @unchecked Sendable {
	let directory: String
	let name: String
	let hasMocks: Bool
	let includeInCoverage: Bool

	// MARK: - Computed Properties

	/// Package reference for Project.swift packages array.
	var packageReference: Package {
		.package(path: Path(stringLiteral: directory))
	}

	/// Target dependency for consuming targets.
	var targetDependency: TargetDependency {
		.package(product: name)
	}

	/// Mocks dependency for consuming targets.
	var mocksTargetDependency: TargetDependency {
		.package(product: "\(name)Mocks")
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

	// MARK: - Factory

	/// Creates a module metadata holder for an SPM local package.
	///
	/// - Parameters:
	///   - directory: The module's directory relative to the workspace root (e.g., "Libraries/Core", "Features/Character", "AppKit").
	///                The last path component is used as the module name (e.g., "Core" → target `ChallengeCore`).
	///   - includeInCoverage: Whether the module's source target should be included in code coverage.
	///                        Defaults to `true`. Set to `false` for infrastructure modules without meaningful source (e.g., Resources, SnapshotTestKit).
	static func create(directory: String, includeInCoverage: Bool = true) -> Module {
		let components = directory.split(separator: "/")
		guard let last = components.last else {
			fatalError("Module directory must not be empty")
		}
		let shortName = String(last)
		let targetName = "\(appName)\(shortName)"

		return Module(
			directory: directory,
			name: targetName,
			hasMocks: hasMocksFolder(directory: directory),
			includeInCoverage: includeInCoverage
		)
	}
}

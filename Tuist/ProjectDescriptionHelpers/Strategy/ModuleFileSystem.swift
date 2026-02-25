import Foundation

/// Filesystem introspection utilities for module directories.
///
/// Detects the presence of source folders (Mocks, Tests, Resources) and derives
/// the target name from the directory path. Separated from `ModuleDefinition`
/// to respect Single Responsibility: `ModuleDefinition` captures configuration,
/// `ModuleFileSystem` handles filesystem queries.
struct ModuleFileSystem {
	private let directory: String
	private let appName: String

	init(directory: String, appName: String) {
		self.directory = directory
		self.appName = appName
	}

	// MARK: - Derived Metadata

	/// Derives the Tuist target name from the module directory path.
	///
	/// Example: `"Features/Character"` -> `"ChallengeCharacter"`
	var targetName: String {
		let components = directory.split(separator: "/")
		guard let last = components.last else {
			fatalError("Module directory must not be empty")
		}
		return "\(self.appName)\(last)"
	}

	/// Whether the module has a Mocks folder with Swift files.
	var hasMocks: Bool {
		folderContainsFiles(at: "Mocks", withExtension: ".swift")
	}

	/// Whether the module has a Tests/Unit folder with Swift files.
	var hasUnitTests: Bool {
		folderContainsFiles(at: "Tests/Unit", withExtension: ".swift")
	}

	/// Whether the module has a Tests/Snapshots folder with Swift files.
	var hasSnapshotTests: Bool {
		folderContainsFiles(at: "Tests/Snapshots", withExtension: ".swift")
	}

	/// Whether the module has a Tests/Shared folder with Swift files.
	var hasSharedTests: Bool {
		folderContainsFiles(at: "Tests/Shared", withExtension: ".swift")
	}

	/// Whether the module has a Sources/Resources folder with any files.
	var hasResources: Bool {
		folderContainsFiles(at: "Sources/Resources")
	}

	/// Whether the module has a Tests/Shared/Fixtures folder with any files.
	var hasSharedFixtures: Bool {
		folderContainsFiles(at: "Tests/Shared/Fixtures")
	}

	/// Whether the module has a Tests/Shared/Resources folder with any files.
	var hasSharedResources: Bool {
		folderContainsFiles(at: "Tests/Shared/Resources")
	}

	/// All `__Snapshots__` directory paths relative to `Tests/`.
	///
	/// Example: `["Snapshots/Presentation/CharacterDetail/__Snapshots__"]`.
	var snapshotExclusions: [String] {
		let testsPath = "\(workspaceRoot)/\(directory)/Tests"
		let fileManager = FileManager.default
		var exclusions: [String] = []

		guard let enumerator = fileManager.enumerator(atPath: testsPath) else {
			return []
		}

		while let path = enumerator.nextObject() as? String {
			if path.hasSuffix("__Snapshots__") {
				var isDirectory: ObjCBool = false
				let fullPath = "\(testsPath)/\(path)"
				if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory),
					isDirectory.boolValue
				{
					exclusions.append(path)
				}
			}
		}

		return exclusions.sorted()
	}

	// MARK: - Private

	/// Checks if a subfolder (relative to the module directory) contains any files.
	private func folderContainsFiles(at subfolder: String, withExtension ext: String? = nil) -> Bool {
		let path = "\(workspaceRoot)/\(directory)/\(subfolder)"
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
}

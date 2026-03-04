import Foundation

/// Generates `Bundle+Module.swift` files for targets with resources.
///
/// Called from `FrameworkModule.init` and `App.project` during manifest evaluation
/// to provide a `Bundle.module` accessor identical to the one SPM auto-generates.
/// Only writes files when the target has resources.
/// Follows the same manifest-time side-effect pattern as `PackageSwiftGenerator`.
enum BundleAccessorGenerator {
	static func generate(directory: String, fileSystem: ModuleFileSystem) {
		if fileSystem.hasResources {
			writeAccessor(to: "\(workspaceRoot)/\(directory)/Sources/Generated")
		}

		if fileSystem.hasSharedResources || fileSystem.hasSharedFixtures {
			writeAccessor(to: "\(workspaceRoot)/\(directory)/Tests/Shared/Generated")
		}
	}

	/// Generates `Bundle+Module.swift` at the given path relative to the workspace root.
	static func generateAt(relativePath: String) {
		writeAccessor(to: "\(workspaceRoot)/\(relativePath)")
	}
}

// MARK: - Private

private extension BundleAccessorGenerator {
	static let content = """
		import Foundation

		private class BundleFinder {}

		extension Foundation.Bundle {
			static let module = Bundle(for: BundleFinder.self)
		}

		"""

	static func writeAccessor(to directoryPath: String) {
		let fileManager = FileManager.default

		if !fileManager.fileExists(atPath: directoryPath) {
			do {
				try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
			} catch {
				fatalError("Failed to create directory at \(directoryPath): \(error)")
			}
		}

		let filePath = "\(directoryPath)/Bundle+Module.swift"
		do {
			try content.write(toFile: filePath, atomically: true, encoding: .utf8)
		} catch {
			fatalError("Failed to write Bundle+Module.swift at \(filePath): \(error)")
		}
	}
}

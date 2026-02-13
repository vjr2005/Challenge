import Foundation

struct FileSystem: FileSystemContract {
	// FileManager is not Sendable but is documented as thread-safe.
	// Safe to use from any isolation domain without synchronization.
	nonisolated(unsafe) private let fileManager: FileManager
	private let resourceKeys: [URLResourceKey] = [.fileSizeKey, .contentModificationDateKey, .creationDateKey]

	init(fileManager: FileManager = .default) {
		self.fileManager = fileManager
	}

	nonisolated func contents(at url: URL) throws -> Data {
		try Data(contentsOf: url)
	}

	nonisolated func write(_ data: Data, to url: URL) throws {
		try data.write(to: url)
	}

	nonisolated func removeItem(at url: URL) throws {
		try fileManager.removeItem(at: url)
	}

	nonisolated func createDirectory(at url: URL) throws {
		try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
	}

	nonisolated func contentsOfDirectory(at url: URL) throws -> [URL] {
		try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: resourceKeys)
	}

	nonisolated func fileAttributes(at url: URL) throws -> FileAttributes {
		let resourceValues = try url.resourceValues(forKeys: Set(resourceKeys))
		return try FileAttributes(
			fileSize: resourceValues.fileSize,
			modificationDate: resourceValues.contentModificationDate,
			creationDate: resourceValues.creationDate
		)
	}

	nonisolated func updateModificationDate(at url: URL) throws {
		try fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: url.path)
	}
}

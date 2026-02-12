import Foundation

struct FileSystem: FileSystemContract {
	// FileManager is not Sendable but is documented as thread-safe.
	// Safe to use from any isolation domain without synchronization.
	nonisolated(unsafe) private let fileManager: FileManager

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
		try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .creationDateKey])
	}

	nonisolated func fileAttributes(at url: URL) throws -> FileAttributes {
		let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey, .creationDateKey])
		guard let size = resourceValues.fileSize,
			  let modified = resourceValues.contentModificationDate,
			  let created = resourceValues.creationDate else {
			throw CocoaError(.fileReadUnknown)
		}
		return FileAttributes(size: size, modified: modified, created: created)
	}

	nonisolated func updateModificationDate(at url: URL) throws {
		try fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: url.path)
	}
}

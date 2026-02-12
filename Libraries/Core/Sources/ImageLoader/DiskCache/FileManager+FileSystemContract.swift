import Foundation

// FileManager is thread-safe but not marked as Sendable in Apple's SDK.
extension FileManager: @retroactive @unchecked Sendable {}

extension FileManager: FileSystemContract {
	nonisolated func contents(at url: URL) throws -> Data {
		try Data(contentsOf: url)
	}

	nonisolated func write(_ data: Data, to url: URL) throws {
		try data.write(to: url)
	}

	nonisolated func createDirectory(at url: URL) throws {
		try createDirectory(at: url, withIntermediateDirectories: true)
	}

	nonisolated func contentsOfDirectory(at url: URL) throws -> [URL] {
		try contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .creationDateKey])
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
		try setAttributes([.modificationDate: Date()], ofItemAtPath: url.path)
	}
}

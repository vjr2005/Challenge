import Foundation

extension FileManager: FileSystemContract {
	func contents(at url: URL) throws -> Data {
		try Data(contentsOf: url)
	}

	func write(_ data: Data, to url: URL) throws {
		try data.write(to: url)
	}

	func removeItem(at url: URL) throws {
		try removeItem(atPath: url.path)
	}

	func createDirectory(at url: URL) throws {
		try createDirectory(at: url, withIntermediateDirectories: true)
	}

	func contentsOfDirectory(at url: URL) throws -> [URL] {
		try contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .creationDateKey])
	}

	func fileAttributes(at url: URL) throws -> FileAttributes {
		let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey, .creationDateKey])
		guard let size = resourceValues.fileSize,
			  let modified = resourceValues.contentModificationDate,
			  let created = resourceValues.creationDate else {
			throw CocoaError(.fileReadUnknown)
		}
		return FileAttributes(size: size, modified: modified, created: created)
	}

	func updateModificationDate(at url: URL) throws {
		try setAttributes([.modificationDate: Date()], ofItemAtPath: url.path)
	}
}

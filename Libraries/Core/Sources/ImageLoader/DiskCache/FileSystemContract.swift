import Foundation

struct FileAttributes: Equatable {
	let size: Int
	let modified: Date
	let created: Date

	nonisolated init(size: Int, modified: Date, created: Date) {
		self.size = size
		self.modified = modified
		self.created = created
	}

	nonisolated init(fileSize: Int?, modificationDate: Date?, creationDate: Date?) throws {
		guard let size = fileSize,
			  let modified = modificationDate,
			  let created = creationDate else {
			throw CocoaError(.fileReadUnknown)
		}
		self.init(size: size, modified: modified, created: created)
	}
}

protocol FileSystemContract: Sendable {
	nonisolated func contents(at url: URL) throws -> Data
	nonisolated func write(_ data: Data, to url: URL) throws
	nonisolated func removeItem(at url: URL) throws
	nonisolated func createDirectory(at url: URL) throws
	nonisolated func contentsOfDirectory(at url: URL) throws -> [URL]
	nonisolated func fileAttributes(at url: URL) throws -> FileAttributes
	nonisolated func updateModificationDate(at url: URL) throws
}

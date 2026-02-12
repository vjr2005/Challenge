import Foundation

struct FileAttributes {
	let size: Int
	let modified: Date
	let created: Date
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

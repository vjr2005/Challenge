import Foundation

struct FileAttributes {
	let size: Int
	let modified: Date
	let created: Date
}

protocol FileSystemContract {
	func contents(at url: URL) throws -> Data
	func write(_ data: Data, to url: URL) throws
	func removeItem(at url: URL) throws
	func createDirectory(at url: URL) throws
	func contentsOfDirectory(at url: URL) throws -> [URL]
	func fileAttributes(at url: URL) throws -> FileAttributes
	func updateModificationDate(at url: URL) throws
}

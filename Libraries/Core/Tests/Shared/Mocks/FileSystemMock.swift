import Foundation

@testable import ChallengeCore

final class FileSystemMock: FileSystemContract {
	// MARK: - Storage

	var files: [URL: Data] = [:]
	var fileCreationDates: [URL: Date] = [:]
	var fileModificationDates: [URL: Date] = [:]

	// MARK: - Error Injection

	var writeError: (any Error)?
	var contentsOfDirectoryError: (any Error)?
	var fileAttributesError: (any Error)?

	// MARK: - Call Tracking

	private(set) var contentsCallCount = 0
	private(set) var writeCallCount = 0
	private(set) var removeItemCallCount = 0
	private(set) var removeItemLastURL: URL?
	private(set) var createDirectoryCallCount = 0
	private(set) var contentsOfDirectoryCallCount = 0
	private(set) var fileAttributesCallCount = 0
	private(set) var updateModificationDateCallCount = 0
	private(set) var updateModificationDateLastURL: URL?

	// MARK: - FileSystemContract

	func contents(at url: URL) throws -> Data {
		contentsCallCount += 1
		guard let data = files[url] else {
			throw CocoaError(.fileReadNoSuchFile)
		}
		return data
	}

	func write(_ data: Data, to url: URL) throws {
		writeCallCount += 1
		if let writeError {
			throw writeError
		}
		files[url] = data
		let now = Date()
		fileCreationDates[url] = fileCreationDates[url] ?? now
		fileModificationDates[url] = now
	}

	func removeItem(at url: URL) throws {
		removeItemCallCount += 1
		removeItemLastURL = url
		files[url] = nil
		fileCreationDates[url] = nil
		fileModificationDates[url] = nil
	}

	func createDirectory(at url: URL) throws {
		createDirectoryCallCount += 1
	}

	func contentsOfDirectory(at url: URL) throws -> [URL] {
		contentsOfDirectoryCallCount += 1
		if let contentsOfDirectoryError {
			throw contentsOfDirectoryError
		}
		return Array(files.keys)
	}

	func fileAttributes(at url: URL) throws -> FileAttributes {
		fileAttributesCallCount += 1
		if let fileAttributesError {
			throw fileAttributesError
		}
		guard files[url] != nil else {
			throw CocoaError(.fileReadNoSuchFile)
		}
		return FileAttributes(
			size: files[url]?.count ?? 0,
			modified: fileModificationDates[url] ?? Date(),
			created: fileCreationDates[url] ?? Date()
		)
	}

	func updateModificationDate(at url: URL) throws {
		updateModificationDateCallCount += 1
		updateModificationDateLastURL = url
		fileModificationDates[url] = Date()
	}
}

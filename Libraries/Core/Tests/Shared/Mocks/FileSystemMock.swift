import Foundation

@testable import ChallengeCore

final class FileSystemMock: FileSystemContract, @unchecked Sendable {
	// MARK: - Storage

	nonisolated(unsafe) var files: [URL: Data] = [:]
	nonisolated(unsafe) var fileCreationDates: [URL: Date] = [:]
	nonisolated(unsafe) var fileModificationDates: [URL: Date] = [:]

	// MARK: - Error Injection

	nonisolated(unsafe) var writeError: (any Error)?
	nonisolated(unsafe) var contentsOfDirectoryError: (any Error)?
	nonisolated(unsafe) var fileAttributesError: (any Error)?

	// MARK: - Call Tracking

	nonisolated(unsafe) private(set) var contentsCallCount = 0
	nonisolated(unsafe) private(set) var writeCallCount = 0
	nonisolated(unsafe) private(set) var removeItemCallCount = 0
	nonisolated(unsafe) private(set) var removeItemLastURL: URL?
	nonisolated(unsafe) private(set) var createDirectoryCallCount = 0
	nonisolated(unsafe) private(set) var contentsOfDirectoryCallCount = 0
	nonisolated(unsafe) private(set) var fileAttributesCallCount = 0
	nonisolated(unsafe) private(set) var updateModificationDateCallCount = 0
	nonisolated(unsafe) private(set) var updateModificationDateLastURL: URL?

	@MainActor init() {}

	// MARK: - FileSystemContract

	nonisolated func contents(at url: URL) throws -> Data {
		contentsCallCount += 1
		guard let data = files[url] else {
			throw CocoaError(.fileReadNoSuchFile)
		}
		return data
	}

	nonisolated func write(_ data: Data, to url: URL) throws {
		writeCallCount += 1
		if let writeError {
			throw writeError
		}
		files[url] = data
		let now = Date()
		fileCreationDates[url] = fileCreationDates[url] ?? now
		fileModificationDates[url] = now
	}

	nonisolated func removeItem(at url: URL) throws {
		removeItemCallCount += 1
		removeItemLastURL = url
		files[url] = nil
		fileCreationDates[url] = nil
		fileModificationDates[url] = nil
	}

	nonisolated func createDirectory(at url: URL) throws {
		createDirectoryCallCount += 1
	}

	nonisolated func contentsOfDirectory(at url: URL) throws -> [URL] {
		contentsOfDirectoryCallCount += 1
		if let contentsOfDirectoryError {
			throw contentsOfDirectoryError
		}
		return Array(files.keys)
	}

	nonisolated func fileAttributes(at url: URL) throws -> FileAttributes {
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

	nonisolated func updateModificationDate(at url: URL) throws {
		updateModificationDateCallCount += 1
		updateModificationDateLastURL = url
		fileModificationDates[url] = Date()
	}
}

import Foundation
import Testing

@testable import ChallengeCore

@Suite(.timeLimit(.minutes(1)))
struct FileSystemTests {
	private let sut: FileSystemContract = FileSystem()
	private let testData = Data("test content".utf8)

	// MARK: - Write and Read

	@Test("Writes data and reads it back")
	func writesAndReadsData() async throws {
		// Given
		let directory = makeTemporaryDirectory()
		let fileURL = directory.appendingPathComponent("test-file")

		// When
		try await sut.write(testData, to: fileURL)
		let result = try await sut.contents(at: fileURL)

		// Then
		#expect(result == testData)
	}

	@Test("Throws error when reading non-existent file")
	func throwsErrorWhenReadingNonExistentFile() async {
		// Given
		let fileURL = URL(fileURLWithPath: "/tmp/non-existent-\(UUID().uuidString)")

		// Then
		do {
			// When
			_ = try await sut.contents(at: fileURL)
			Issue.record("Expected error to be thrown")
		} catch {
			// Expected
		}
	}

	// MARK: - Create Directory

	@Test("Creates directory with intermediate directories")
	func createsDirectoryWithIntermediateDirectories() async throws {
		// Given
		let directory = FileManager.default.temporaryDirectory
			.appendingPathComponent(UUID().uuidString)
			.appendingPathComponent("nested")

		// When
		try await sut.createDirectory(at: directory)

		// Then
		var isDirectory: ObjCBool = false
		let exists = FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDirectory)
		#expect(exists)
		#expect(isDirectory.boolValue)
	}

	// MARK: - Remove Item

	@Test("Removes file from disk")
	func removesFile() async throws {
		// Given
		let directory = makeTemporaryDirectory()
		let fileURL = directory.appendingPathComponent("to-remove")
		try await sut.write(testData, to: fileURL)

		// When
		try await sut.removeItem(at: fileURL)

		// Then
		#expect(!FileManager.default.fileExists(atPath: fileURL.path))
	}

	// MARK: - Contents of Directory

	@Test("Lists files in directory")
	func listsFilesInDirectory() async throws {
		// Given
		let directory = makeTemporaryDirectory()
		try await sut.write(testData, to: directory.appendingPathComponent("file1"))
		try await sut.write(testData, to: directory.appendingPathComponent("file2"))

		// When
		let files = try await sut.contentsOfDirectory(at: directory)

		// Then
		#expect(files.count == 2)
	}

	// MARK: - File Attributes

	@Test("Returns file attributes with size and dates")
	func returnsFileAttributes() async throws {
		// Given
		let directory = makeTemporaryDirectory()
		let fileURL = directory.appendingPathComponent("attributes-test")
		try await sut.write(testData, to: fileURL)

		// When
		let attributes = try await sut.fileAttributes(at: fileURL)

		// Then
		#expect(attributes.size == testData.count)
		#expect(attributes.created <= Date())
		#expect(attributes.modified <= Date())
	}

	@Test("Throws error when file attributes are unavailable")
	func throwsErrorWhenFileAttributesAreUnavailable() async {
		// Given
		let fileURL = URL(fileURLWithPath: "/tmp/non-existent-\(UUID().uuidString)")

		// Then
		do {
			// When
			_ = try await sut.fileAttributes(at: fileURL)
			Issue.record("Expected error to be thrown")
		} catch {
			// Expected
		}
	}

	// MARK: - Update Modification Date

	@Test("Updates file modification date")
	func updatesModificationDate() async throws {
		// Given
		let directory = makeTemporaryDirectory()
		let fileURL = directory.appendingPathComponent("touch-test")
		try await sut.write(testData, to: fileURL)
		let originalAttributes = try await sut.fileAttributes(at: fileURL)

		// Small delay to ensure date difference
		try await Task.sleep(for: .milliseconds(10))

		// When
		try await sut.updateModificationDate(at: fileURL)

		// Then
		let updatedAttributes = try await sut.fileAttributes(at: fileURL)
		#expect(updatedAttributes.modified >= originalAttributes.modified)
	}
}

// MARK: - Helpers

private extension FileSystemTests {
	func makeTemporaryDirectory() -> URL {
		let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
		try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
		return directory
	}
}

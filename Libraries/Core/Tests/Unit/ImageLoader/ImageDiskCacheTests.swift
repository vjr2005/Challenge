import Foundation
import Testing

@testable import ChallengeCore

@Suite(.timeLimit(.minutes(1)))
struct ImageDiskCacheTests {
	/// Minimal valid 1x1 red PNG.
	private let testImageData = Data(base64Encoded: """
		iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==
		""")

	private let testURL = URL(string: "https://example.com/image.png")!  // swiftlint:disable:this force_unwrapping

	// MARK: - Retrieval

	@Test("Returns nil when URL is not in cache")
	func imageReturnsNilWhenNotCached() async {
		// Given
		let fileSystemMock = FileSystemMock()
		let sut = ImageDiskCache(
			configuration: makeConfiguration(),
			fileSystem: fileSystemMock
		)

		// When
		let result = await sut.image(for: testURL)

		// Then
		#expect(result == nil)
	}

	@Test("Returns image after storing data")
	func imageReturnsImageAfterStore() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		let sut = ImageDiskCache(
			configuration: makeConfiguration(),
			fileSystem: fileSystemMock
		)
		let imageData = try #require(testImageData)

		// When
		await sut.store(imageData, for: testURL)
		let result = await sut.image(for: testURL)

		// Then
		#expect(result != nil)
	}

	// MARK: - Directory Creation

	@Test("Creates directory when storing data")
	func createsDirectoryWhenStoring() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		let sut = ImageDiskCache(
			configuration: makeConfiguration(),
			fileSystem: fileSystemMock
		)
		let imageData = try #require(testImageData)

		// When
		await sut.store(imageData, for: testURL)

		// Then
		#expect(fileSystemMock.createDirectoryCallCount == 1)
	}

	// MARK: - SHA256 Hashing

	@Test("Uses SHA256 hash for file name")
	func usesSHA256ForFileName() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		let sut = ImageDiskCache(
			configuration: makeConfiguration(),
			fileSystem: fileSystemMock
		)
		let imageData = try #require(testImageData)

		// When
		await sut.store(imageData, for: testURL)

		// Then
		let storedURLs = Array(fileSystemMock.files.keys)
		#expect(storedURLs.count == 1)
		let fileName = try #require(storedURLs.first?.lastPathComponent)
		#expect(fileName.count == 64)
		#expect(fileName.allSatisfy { $0.isHexDigit })
	}

	// MARK: - Modification Date Update

	@Test("Updates modification date on read for LRU eviction")
	func updatesModificationDateOnRead() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		let sut = ImageDiskCache(
			configuration: makeConfiguration(),
			fileSystem: fileSystemMock
		)
		let imageData = try #require(testImageData)
		await sut.store(imageData, for: testURL)

		// When
		_ = await sut.image(for: testURL)

		// Then
		#expect(fileSystemMock.updateModificationDateCallCount == 1)
	}

	// MARK: - Eviction

	@Test("Evicts oldest files when exceeding max size")
	func evictsOldestFilesWhenExceedingMaxSize() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		let imageData = try #require(testImageData)
		let maxSize = imageData.count * 2
		let sut = ImageDiskCache(
			configuration: makeConfiguration(maxSize: maxSize),
			fileSystem: fileSystemMock
		)
		let url1 = URL(string: "https://example.com/1.png")!  // swiftlint:disable:this force_unwrapping
		let url2 = URL(string: "https://example.com/2.png")!  // swiftlint:disable:this force_unwrapping
		let url3 = URL(string: "https://example.com/3.png")!  // swiftlint:disable:this force_unwrapping

		// When
		await sut.store(imageData, for: url1)
		await sut.store(imageData, for: url2)
		await sut.store(imageData, for: url3)

		// Then
		#expect(fileSystemMock.files.count <= 2)
		#expect(fileSystemMock.removeItemCallCount > 0)
	}

	@Test("Skips eviction when directory listing fails")
	func skipsEvictionWhenDirectoryListingFails() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		let imageData = try #require(testImageData)
		let sut = ImageDiskCache(
			configuration: makeConfiguration(maxSize: imageData.count),
			fileSystem: fileSystemMock
		)
		await sut.store(imageData, for: testURL)
		fileSystemMock.contentsOfDirectoryError = CocoaError(.fileReadNoSuchFile)

		// When
		let secondURL = try #require(URL(string: "https://example.com/2.png"))
		await sut.store(imageData, for: secondURL)

		// Then — file was written but eviction was skipped
		#expect(fileSystemMock.writeCallCount == 2)
		#expect(fileSystemMock.removeItemCallCount == 0)
	}

	@Test("Does not evict when under max size")
	func doesNotEvictWhenUnderMaxSize() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		let imageData = try #require(testImageData)
		let sut = ImageDiskCache(
			configuration: makeConfiguration(maxSize: imageData.count * 10),
			fileSystem: fileSystemMock
		)

		// When
		await sut.store(imageData, for: testURL)

		// Then
		#expect(fileSystemMock.removeItemCallCount == 0)
	}

	// MARK: - Remove

	@Test("Removes specific file from disk")
	func removesSpecificFile() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		let sut = ImageDiskCache(
			configuration: makeConfiguration(),
			fileSystem: fileSystemMock
		)
		let imageData = try #require(testImageData)
		let otherURL = try #require(URL(string: "https://example.com/other.png"))
		await sut.store(imageData, for: testURL)
		await sut.store(imageData, for: otherURL)

		// When
		await sut.remove(for: testURL)

		// Then — verify through actor (avoids cross-thread mock access)
		let removedResult = await sut.image(for: testURL)
		let otherResult = await sut.image(for: otherURL)
		#expect(removedResult == nil)
		#expect(otherResult != nil)
	}

	// MARK: - Remove All

	@Test("removeAll does nothing when directory listing fails")
	func removeAllDoesNothingWhenDirectoryListingFails() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		let sut = ImageDiskCache(
			configuration: makeConfiguration(),
			fileSystem: fileSystemMock
		)
		let imageData = try #require(testImageData)
		await sut.store(imageData, for: testURL)
		fileSystemMock.contentsOfDirectoryError = CocoaError(.fileReadNoSuchFile)

		// When
		await sut.removeAll()

		// Then
		#expect(fileSystemMock.removeItemCallCount == 0)
	}

	@Test("removeAll clears all files")
	func removeAllClearsAllFiles() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		let sut = ImageDiskCache(
			configuration: makeConfiguration(),
			fileSystem: fileSystemMock
		)
		let imageData = try #require(testImageData)
		let url1 = URL(string: "https://example.com/1.png")!  // swiftlint:disable:this force_unwrapping
		let url2 = URL(string: "https://example.com/2.png")!  // swiftlint:disable:this force_unwrapping
		await sut.store(imageData, for: url1)
		await sut.store(imageData, for: url2)

		// When
		await sut.removeAll()

		// Then — verify through actor (avoids cross-thread mock access)
		let result1 = await sut.image(for: url1)
		let result2 = await sut.image(for: url2)
		#expect(result1 == nil)
		#expect(result2 == nil)
	}

	// MARK: - Empty Data

	@Test("Does not store empty data")
	func doesNotStoreEmptyData() async {
		// Given
		let fileSystemMock = FileSystemMock()
		let sut = ImageDiskCache(
			configuration: makeConfiguration(),
			fileSystem: fileSystemMock
		)

		// When
		await sut.store(Data(), for: testURL)

		// Then
		#expect(fileSystemMock.writeCallCount == 0)
		#expect(fileSystemMock.files.isEmpty)
	}

	// MARK: - Write Error

	@Test("Handles write error without crash")
	func handlesWriteErrorWithoutCrash() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		fileSystemMock.writeError = CocoaError(.fileWriteOutOfSpace)
		let sut = ImageDiskCache(
			configuration: makeConfiguration(),
			fileSystem: fileSystemMock
		)
		let imageData = try #require(testImageData)

		// When
		await sut.store(imageData, for: testURL)

		// Then
		#expect(fileSystemMock.files.isEmpty)
	}

	// MARK: - TTL

	@Test("Returns nil and removes file when TTL has expired")
	func returnsNilWhenTTLExpired() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		let sut = ImageDiskCache(
			configuration: makeConfiguration(timeToLive: 60),
			fileSystem: fileSystemMock
		)
		let imageData = try #require(testImageData)
		await sut.store(imageData, for: testURL)

		// Simulate creation date in the past (beyond TTL)
		let storedURL = try #require(fileSystemMock.files.keys.first)
		fileSystemMock.fileCreationDates[storedURL] = Date().addingTimeInterval(-120)

		// When
		let result = await sut.image(for: testURL)

		// Then
		#expect(result == nil)
		#expect(fileSystemMock.files[storedURL] == nil)
	}

	@Test("Removes file and returns nil when attributes cannot be read")
	func removesFileWhenAttributesCannotBeRead() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		let sut = ImageDiskCache(
			configuration: makeConfiguration(),
			fileSystem: fileSystemMock
		)
		let imageData = try #require(testImageData)
		await sut.store(imageData, for: testURL)
		fileSystemMock.fileAttributesError = CocoaError(.fileReadUnknown)

		// When
		let result = await sut.image(for: testURL)

		// Then
		#expect(result == nil)
		#expect(fileSystemMock.removeItemCallCount == 1)
	}

	@Test("Removes files with unreadable attributes during eviction")
	func removesFilesWithUnreadableAttributesDuringEviction() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		let imageData = try #require(testImageData)
		let sut = ImageDiskCache(
			configuration: makeConfiguration(maxSize: imageData.count * 10),
			fileSystem: fileSystemMock
		)
		await sut.store(imageData, for: testURL)
		fileSystemMock.fileAttributesError = CocoaError(.fileReadUnknown)
		let secondURL = try #require(URL(string: "https://example.com/2.png"))

		// When
		await sut.store(imageData, for: secondURL)

		// Then — both files have unreadable attributes, both are removed
		#expect(fileSystemMock.removeItemCallCount == 2)
	}

	@Test("Returns image when TTL has not expired")
	func returnsImageWhenTTLNotExpired() async throws {
		// Given
		let fileSystemMock = FileSystemMock()
		let sut = ImageDiskCache(
			configuration: makeConfiguration(timeToLive: 3600),
			fileSystem: fileSystemMock
		)
		let imageData = try #require(testImageData)
		await sut.store(imageData, for: testURL)

		// When
		let result = await sut.image(for: testURL)

		// Then
		#expect(result != nil)
	}
}

// MARK: - Helpers

private extension ImageDiskCacheTests {
	func makeConfiguration(
		maxSize: Int = 100 * 1_024 * 1_024,
		timeToLive: TimeInterval = 604_800
	) -> DiskCacheConfiguration {
		DiskCacheConfiguration(
			maxSize: maxSize,
			timeToLive: timeToLive,
			directory: URL(fileURLWithPath: "/tmp/test-image-cache")
		)
	}
}

import ChallengeCoreMocks
import Foundation
import Testing
import UIKit

@testable import ChallengeCore

@Suite(.timeLimit(.minutes(1)))
struct CachedImageLoaderTests {
	/// Minimal valid 1x1 red PNG - no rendering system dependencies for CI headless environments.
	private let testImageData = Data(base64Encoded: """
		iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==
		""")

	private let fileSystemMock = FileSystemMock()

	// MARK: - Cached Image

	@Test("Cached image returns nil when URL is not in cache")
	func cachedImageForURLReturnsNilWhenNotCached() throws {
		// Given
		let url = try #require(URL(string: "https://test-cached-nil.example.com/image.png"))
		let sut = makeSUT()

		// When
		let result = sut.cachedImage(for: url)

		// Then
		#expect(result == nil)
	}

	@Test("Cached image returns image after successful load")
	func cachedImageForURLReturnsImageAfterLoading() async throws {
		// Given
		let url = try #require(URL(string: "https://test-cached-after-load.example.com/image.png"))
		givenSuccessResponse(for: url, data: testImageData)
		let sut = makeSUT()

		// When
		_ = await sut.image(for: url)
		let cachedResult = sut.cachedImage(for: url)

		// Then
		#expect(cachedResult != nil)
	}

	// MARK: - Image Loading

	@Test("Image loading returns image on success")
	func imageForURLReturnsImageOnSuccess() async throws {
		// Given
		let url = try #require(URL(string: "https://test-image-success.example.com/image.png"))
		givenSuccessResponse(for: url, data: testImageData)
		let sut = makeSUT()

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result != nil)
	}

	@Test("Image loading returns nil on network error")
	func imageForURLReturnsNilOnNetworkError() async throws {
		// Given
		let url = try #require(URL(string: "https://test-network-error.example.com/image.png"))
		givenNetworkError(for: url)
		let sut = makeSUT()

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result == nil)
	}

	@Test("Image loading returns nil on error status code")
	func imageForURLReturnsNilOnErrorStatusCode() async throws {
		// Given
		let url = try #require(URL(string: "https://test-error-status.example.com/image.png"))
		givenErrorResponse(for: url, statusCode: 404)
		let sut = makeSUT()

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result == nil)
	}

	@Test("Image loading returns nil for invalid image data")
	func imageForURLReturnsNilForInvalidImageData() async throws {
		// Given
		let url = try #require(URL(string: "https://test-invalid-data.example.com/image.png"))
		givenSuccessResponse(for: url, data: Data("not an image".utf8))
		let sut = makeSUT()

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result == nil)
	}

	@Test("Image loading uses cache on second request")
	func imageForURLReturnsCachedImageOnSecondRequest() async throws {
		// Given
		let url = try #require(URL(string: "https://test-cached-second.example.com/image.png"))
		let requestCount = RequestCounter()
		givenSuccessResponse(for: url, data: testImageData) {
			Task { await requestCount.increment() }
		}
		let sut = makeSUT()

		// When
		_ = await sut.image(for: url)
		_ = await sut.image(for: url)

		// Then
		try await Task.sleep(for: .milliseconds(50))
		let count = await requestCount.value
		#expect(count == 1)
	}

	// MARK: - Request Deduplication

	@Test("Concurrent requests for same URL are deduplicated")
	func concurrentRequestsForSameURLAreDeduplicated() async throws {
		// Given
		let url = try #require(URL(string: "https://test-dedup-same.example.com/image.png"))
		let requestCount = RequestCounter()
		givenSuccessResponse(for: url, data: testImageData) {
			Task { await requestCount.increment() }
			Thread.sleep(forTimeInterval: 0.1)
		}
		let sut = makeSUT()

		// When - Launch two concurrent requests for the same URL
		async let image1 = sut.image(for: url)
		async let image2 = sut.image(for: url)

		let results = await [image1, image2]

		// Then - Both should succeed but only one network request should be made
		#expect(results[0] != nil)
		#expect(results[1] != nil)
		let count = await requestCount.value
		#expect(count == 1)
	}

	@Test("Concurrent requests for different URLs make separate network requests")
	func concurrentRequestsForDifferentURLsAreNotDeduplicated() async throws {
		// Given
		let url1 = try #require(URL(string: "https://test-dedup-different.example.com/image1.png"))
		let url2 = try #require(URL(string: "https://test-dedup-different.example.com/image2.png"))
		let requestCount = RequestCounter()
		givenSuccessResponse(for: url1, data: testImageData) {
			Task { await requestCount.increment() }
			Thread.sleep(forTimeInterval: 0.05)
		}
		let sut = makeSUT()

		// When - Launch two concurrent requests for different URLs
		async let image1 = sut.image(for: url1)
		async let image2 = sut.image(for: url2)

		let results = await [image1, image2]

		// Then - Both should make separate network requests
		#expect(results[0] != nil)
		#expect(results[1] != nil)
		let count = await requestCount.value
		#expect(count == 2)
	}

	// MARK: - Disk Cache Integration

	@Test("Stores image to disk after network fetch")
	func storesImageToDiskAfterNetworkFetch() async throws {
		// Given
		let url = try #require(URL(string: "https://test-disk-store.example.com/image.png"))
		let fileSystemMock = FileSystemMock()
		let diskCache = ImageDiskCache(
			configuration: DiskCacheConfiguration(
				maxSize: 100 * 1_024 * 1_024,
				timeToLive: 604_800,
				directory: URL(fileURLWithPath: "/tmp/test-cache")
			),
			fileSystem: fileSystemMock
		)
		givenSuccessResponse(for: url, data: testImageData)
		let sut = CachedImageLoader(session: .mockSession(), diskCache: diskCache)

		// When
		_ = await sut.image(for: url)

		// Then
		#expect(fileSystemMock.writeCallCount == 1)
		#expect(!fileSystemMock.files.isEmpty)
	}

	@Test("Returns image from disk when memory cache is empty")
	func returnsImageFromDiskWhenMemoryCacheIsEmpty() async throws {
		// Given
		let url = try #require(URL(string: "https://test-disk-read.example.com/image.png"))
		let fileSystemMock = FileSystemMock()
		let diskCache = ImageDiskCache(
			configuration: DiskCacheConfiguration(
				maxSize: 100 * 1_024 * 1_024,
				timeToLive: 604_800,
				directory: URL(fileURLWithPath: "/tmp/test-cache")
			),
			fileSystem: fileSystemMock
		)
		let requestCount = RequestCounter()
		givenSuccessResponse(for: url, data: testImageData) {
			Task { await requestCount.increment() }
		}

		// Store data via first loader (populates disk)
		let firstLoader = CachedImageLoader(session: .mockSession(), diskCache: diskCache)
		_ = await firstLoader.image(for: url)

		// Create second loader sharing same disk cache (empty memory)
		let sut = CachedImageLoader(session: .mockSession(), diskCache: diskCache)

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result != nil)
		try await Task.sleep(for: .milliseconds(50))
		let count = await requestCount.value
		#expect(count == 1)
	}

	// MARK: - Remove Image

	@Test("removeImage removes image from memory and disk")
	func removeImageRemovesFromMemoryAndDisk() async throws {
		// Given
		let url = try #require(URL(string: "https://test-remove-image.example.com/image.png"))
		let fileSystemMock = FileSystemMock()
		let diskCache = ImageDiskCache(
			configuration: DiskCacheConfiguration(
				maxSize: 100 * 1_024 * 1_024,
				timeToLive: 604_800,
				directory: URL(fileURLWithPath: "/tmp/test-cache")
			),
			fileSystem: fileSystemMock
		)
		givenSuccessResponse(for: url, data: testImageData)
		let sut = CachedImageLoader(session: .mockSession(), diskCache: diskCache)
		_ = await sut.image(for: url)

		// When
		await sut.removeImage(for: url)

		// Then
		#expect(sut.cachedImage(for: url) == nil)
		#expect(fileSystemMock.removeItemCallCount == 1)
	}

	// MARK: - Clear Cache

	@Test("clearCache clears both memory and disk")
	func clearCacheClearsBothMemoryAndDisk() async throws {
		// Given
		let url = try #require(URL(string: "https://test-clear-cache.example.com/image.png"))
		let fileSystemMock = FileSystemMock()
		let diskCache = ImageDiskCache(
			configuration: DiskCacheConfiguration(
				maxSize: 100 * 1_024 * 1_024,
				timeToLive: 604_800,
				directory: URL(fileURLWithPath: "/tmp/test-cache")
			),
			fileSystem: fileSystemMock
		)
		givenSuccessResponse(for: url, data: testImageData)
		let sut = CachedImageLoader(session: .mockSession(), diskCache: diskCache)
		_ = await sut.image(for: url)

		// When
		await sut.clearCache()

		// Then
		#expect(sut.cachedImage(for: url) == nil)
		#expect(fileSystemMock.files.isEmpty)
	}
}

// MARK: - Helpers

private extension CachedImageLoaderTests {
	func makeSUT(session: URLSession = .mockSession()) -> CachedImageLoader {
		let diskCache = ImageDiskCache(
			configuration: DiskCacheConfiguration(
				maxSize: 100 * 1_024 * 1_024,
				timeToLive: 604_800,
				directory: URL(fileURLWithPath: "/tmp/test-cache")
			),
			fileSystem: fileSystemMock
		)
		return CachedImageLoader(session: session, diskCache: diskCache)
	}

	func givenSuccessResponse(for url: URL, data: Data?, onRequest: @escaping @Sendable () -> Void = {}) {
		URLProtocolMock.setHandler({ request in
			onRequest()
			guard let requestURL = request.url else {
				throw URLError(.badURL)
			}
			let response = HTTPURLResponse(url: requestURL, statusCode: 200, httpVersion: nil, headerFields: nil)
			return (try #require(response), data)
		}, forURL: url)
	}

	func givenNetworkError(for url: URL) {
		URLProtocolMock.setHandler({ _ in
			throw URLError(.notConnectedToInternet)
		}, forURL: url)
	}

	func givenErrorResponse(for url: URL, statusCode: Int) {
		URLProtocolMock.setHandler({ request in
			guard let requestURL = request.url else {
				throw URLError(.badURL)
			}
			let response = HTTPURLResponse(url: requestURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)
			return (try #require(response), nil)
		}, forURL: url)
	}
}

// MARK: - Request Counter

private actor RequestCounter {
	var value = 0

	func increment() {
		value += 1
	}
}

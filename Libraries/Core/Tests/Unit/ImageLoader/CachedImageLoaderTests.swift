import ChallengeCoreMocks
import Foundation
import Testing
import UIKit

@testable import ChallengeCore

@Suite(.timeLimit(.minutes(1)))
struct CachedImageLoaderTests {
	// MARK: - Cached Image

	@Test("Cached image returns nil when URL is not in cache")
	func cachedImageForURLReturnsNilWhenNotCached() throws {
		// Given
		let url = try #require(URL(string: "https://test-cached-nil.example.com/image.png"))
		let sut = CachedImageLoader(session: .mockSession())

		// When
		let result = sut.cachedImage(for: url)

		// Then
		#expect(result == nil)
	}

	@Test("Cached image returns image after successful load")
	func cachedImageForURLReturnsImageAfterLoading() async throws {
		// Given
		let url = try #require(URL(string: "https://test-cached-after-load.example.com/image.png"))
		let testImageData = UIImage.checkmark.pngData()

		URLProtocolMock.setHandler({ request in
			guard let requestURL = request.url else {
				throw URLError(.badURL)
			}
			let response = HTTPURLResponse(
				url: requestURL,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)
			return (try #require(response), testImageData)
		}, forURL: url)

		let sut = CachedImageLoader(session: .mockSession())

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
		let testImageData = UIImage.checkmark.pngData()

		URLProtocolMock.setHandler({ request in
			guard let requestURL = request.url else {
				throw URLError(.badURL)
			}
			let response = HTTPURLResponse(
				url: requestURL,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)
			return (try #require(response), testImageData)
		}, forURL: url)

		let sut = CachedImageLoader(session: .mockSession())

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result != nil)
	}

	@Test("Image loading returns nil on network error")
	func imageForURLReturnsNilOnNetworkError() async throws {
		// Given
		let url = try #require(URL(string: "https://test-network-error.example.com/image.png"))

		URLProtocolMock.setHandler({ _ in
			throw URLError(.notConnectedToInternet)
		}, forURL: url)

		let sut = CachedImageLoader(session: .mockSession())

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result == nil)
	}

	@Test("Image loading returns nil on error status code")
	func imageForURLReturnsNilOnErrorStatusCode() async throws {
		// Given
		let url = try #require(URL(string: "https://test-error-status.example.com/image.png"))

		URLProtocolMock.setHandler({ request in
			guard let requestURL = request.url else {
				throw URLError(.badURL)
			}
			let response = HTTPURLResponse(
				url: requestURL,
				statusCode: 404,
				httpVersion: nil,
				headerFields: nil
			)
			return (try #require(response), nil)
		}, forURL: url)

		let sut = CachedImageLoader(session: .mockSession())

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result == nil)
	}

	@Test("Image loading returns nil for invalid image data")
	func imageForURLReturnsNilForInvalidImageData() async throws {
		// Given
		let url = try #require(URL(string: "https://test-invalid-data.example.com/image.png"))
		let invalidData = Data("not an image".utf8)

		URLProtocolMock.setHandler({ request in
			guard let requestURL = request.url else {
				throw URLError(.badURL)
			}
			let response = HTTPURLResponse(
				url: requestURL,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)
			return (try #require(response), invalidData)
		}, forURL: url)

		let sut = CachedImageLoader(session: .mockSession())

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result == nil)
	}

	@Test("Image loading uses cache on second request")
	func imageForURLReturnsCachedImageOnSecondRequest() async throws {
		// Given
		let url = try #require(URL(string: "https://test-cached-second.example.com/image.png"))
		let testImageData = UIImage.checkmark.pngData()
		let requestCount = RequestCounter()

		URLProtocolMock.setHandler({ request in
			Task { await requestCount.increment() }
			guard let requestURL = request.url else {
				throw URLError(.badURL)
			}
			let response = HTTPURLResponse(
				url: requestURL,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)
			return (try #require(response), testImageData)
		}, forURL: url)

		let sut = CachedImageLoader(session: .mockSession())

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
		let testImageData = UIImage.checkmark.pngData()
		let requestCount = RequestCounter()

		URLProtocolMock.setHandler({ request in
			Task { await requestCount.increment() }
			// Add delay to ensure requests overlap
			Thread.sleep(forTimeInterval: 0.1)
			guard let requestURL = request.url else {
				throw URLError(.badURL)
			}
			let response = HTTPURLResponse(
				url: requestURL,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)
			return (try #require(response), testImageData)
		}, forURL: url)

		let sut = CachedImageLoader(session: .mockSession())

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

	@Test("Concurrent requests for different URLs make separate requests")
	func concurrentRequestsForDifferentURLsAreNotDeduplicated() async throws {
		// Given
		let url1 = try #require(URL(string: "https://test-dedup-different.example.com/image1.png"))
		let url2 = try #require(URL(string: "https://test-dedup-different.example.com/image2.png"))
		let testImageData = UIImage.checkmark.pngData()
		let requestCount = RequestCounter()

		URLProtocolMock.setHandler({ request in
			Task { await requestCount.increment() }
			Thread.sleep(forTimeInterval: 0.05)
			guard let requestURL = request.url else {
				throw URLError(.badURL)
			}
			let response = HTTPURLResponse(
				url: requestURL,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)
			return (try #require(response), testImageData)
		}, forURL: url1)

		let sut = CachedImageLoader(session: .mockSession())

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
}

// MARK: - Request Counter

private actor RequestCounter {
	var value = 0

	func increment() {
		value += 1
	}
}

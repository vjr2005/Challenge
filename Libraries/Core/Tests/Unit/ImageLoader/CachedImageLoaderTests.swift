import ChallengeNetworkingMocks
import Foundation
import Testing
import UIKit

@testable import ChallengeCore
@testable import ChallengeNetworking

@Suite(.serialized, .timeLimit(.minutes(1)))
struct CachedImageLoaderTests {
	/// Minimal valid 1x1 red PNG - no rendering system dependencies for CI headless environments.
	private let testImageData = Data(base64Encoded: """
		iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==
		""")

	// MARK: - Cached Image

	@Test("Cached image returns nil when URL is not in cache")
	func cachedImageForURLReturnsNilWhenNotCached() throws {
		// Given
		let url = try #require(URL(string: "https://test-cached-nil.example.com/image.png"))
		let transport = HTTPTransportMock()
		let sut = CachedImageLoader(transport: transport)

		// When
		let result = sut.cachedImage(for: url)

		// Then
		#expect(result == nil)
	}

	@Test("Cached image returns image after successful load")
	func cachedImageForURLReturnsImageAfterLoading() async throws {
		// Given
		let url = try #require(URL(string: "https://test-cached-after-load.example.com/image.png"))
		let testImageData = try #require(self.testImageData)
		let transport = HTTPTransportMock()
		await transport.setResult(.success((testImageData, mockResponse(url: url))))
		let sut = CachedImageLoader(transport: transport)

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
		let testImageData = try #require(self.testImageData)
		let transport = HTTPTransportMock()
		await transport.setResult(.success((testImageData, mockResponse(url: url))))
		let sut = CachedImageLoader(transport: transport)

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result != nil)
	}

	@Test("Image loading returns nil on network error")
	func imageForURLReturnsNilOnNetworkError() async throws {
		// Given
		let url = try #require(URL(string: "https://test-network-error.example.com/image.png"))
		let transport = HTTPTransportMock()
		await transport.setResult(.failure(URLError(.notConnectedToInternet)))
		let sut = CachedImageLoader(transport: transport)

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result == nil)
	}

	@Test("Image loading returns nil on error status code")
	func imageForURLReturnsNilOnErrorStatusCode() async throws {
		// Given
		let url = try #require(URL(string: "https://test-error-status.example.com/image.png"))
		let transport = HTTPTransportMock()
		await transport.setResult(.success((Data(), mockResponse(url: url, statusCode: 404))))
		let sut = CachedImageLoader(transport: transport)

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
		let transport = HTTPTransportMock()
		await transport.setResult(.success((invalidData, mockResponse(url: url))))
		let sut = CachedImageLoader(transport: transport)

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result == nil)
	}

	@Test("Image loading uses cache on second request")
	func imageForURLReturnsCachedImageOnSecondRequest() async throws {
		// Given
		let url = try #require(URL(string: "https://test-cached-second.example.com/image.png"))
		let testImageData = try #require(self.testImageData)
		let transport = HTTPTransportMock()
		await transport.setResult(.success((testImageData, mockResponse(url: url))))
		let sut = CachedImageLoader(transport: transport)

		// When
		_ = await sut.image(for: url)
		_ = await sut.image(for: url)

		// Then
		let sentRequests = await transport.sentRequests
		#expect(sentRequests.count == 1)
	}

	// MARK: - Request Deduplication

	@Test("Concurrent requests for same URL are deduplicated")
	func concurrentRequestsForSameURLAreDeduplicated() async throws {
		// Given
		let url = try #require(URL(string: "https://test-dedup-same.example.com/image.png"))
		let testImageData = try #require(self.testImageData)
		let transport = DelayedHTTPTransportMock(
			result: .success((testImageData, mockResponse(url: url))),
			delay: 0.1
		)
		let sut = CachedImageLoader(transport: transport)

		// When - Launch two concurrent requests for the same URL
		async let image1 = sut.image(for: url)
		async let image2 = sut.image(for: url)

		let results = await [image1, image2]

		// Then - Both should succeed but only one network request should be made
		#expect(results[0] != nil)
		#expect(results[1] != nil)
		let sentRequests = await transport.sentRequests
		#expect(sentRequests.count == 1)
	}

	@Test("Concurrent requests for different URLs make separate requests")
	func concurrentRequestsForDifferentURLsAreNotDeduplicated() async throws {
		// Given
		let url1 = try #require(URL(string: "https://test-dedup-different.example.com/image1.png"))
		let url2 = try #require(URL(string: "https://test-dedup-different.example.com/image2.png"))
		let testImageData = try #require(self.testImageData)
		let transport = DelayedHTTPTransportMock(
			result: .success((testImageData, mockResponse(url: url1))),
			delay: 0.05
		)
		let sut = CachedImageLoader(transport: transport)

		// When - Launch two concurrent requests for different URLs
		async let image1 = sut.image(for: url1)
		async let image2 = sut.image(for: url2)

		let results = await [image1, image2]

		// Then - Both should make separate network requests
		#expect(results[0] != nil)
		#expect(results[1] != nil)
		let sentRequests = await transport.sentRequests
		#expect(sentRequests.count == 2)
	}

	// MARK: - Helpers

	private func mockResponse(url: URL, statusCode: Int = 200) -> HTTPURLResponse {
		guard let response = HTTPURLResponse(
			url: url,
			statusCode: statusCode,
			httpVersion: "HTTP/1.1",
			headerFields: nil
		) else {
			fatalError("Failed to create mock HTTPURLResponse")
		}
		return response
	}
}

// MARK: - Delayed Transport Mock

/// A mock transport that adds a delay before returning, useful for testing request deduplication.
private actor DelayedHTTPTransportMock: HTTPTransportContract {
	private let result: Result<(Data, HTTPURLResponse), Error>
	private let delay: TimeInterval
	private(set) var sentRequests: [URLRequest] = []

	init(result: Result<(Data, HTTPURLResponse), Error>, delay: TimeInterval) {
		self.result = result
		self.delay = delay
	}

	nonisolated func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
		await recordRequest(request)
		try await Task.sleep(for: .seconds(delay))
		return try await getResult()
	}

	private func recordRequest(_ request: URLRequest) {
		sentRequests.append(request)
	}

	private func getResult() throws -> (Data, HTTPURLResponse) {
		try result.get()
	}
}

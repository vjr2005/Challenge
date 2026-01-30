import Foundation
import Testing
import UIKit

@testable import ChallengeCore

@Suite(.timeLimit(.minutes(1)))
struct CachedImageLoaderTests {
	// MARK: - Cached Image

	@Test
	func cachedImageForURLReturnsNilWhenNotCached() throws {
		// Given
		let sut = CachedImageLoader(session: .mockSession())
		let url = try #require(URL(string: "https://test-cached-nil.example.com/image.png"))

		// When
		let result = sut.cachedImage(for: url)

		// Then
		#expect(result == nil)
	}

	@Test
	func cachedImageForURLReturnsImageAfterLoading() async throws {
		// Given
		let testImageData = UIImage.checkmark.pngData()
		let url = try #require(URL(string: "https://test-cached-after-load.example.com/image.png"))

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
		}, forHost: "test-cached-after-load.example.com")

		let sut = CachedImageLoader(session: .mockSession())

		// When
		_ = await sut.image(for: url)
		let cachedResult = sut.cachedImage(for: url)

		// Then
		#expect(cachedResult != nil)
	}

	// MARK: - Image Loading

	@Test
	func imageForURLReturnsImageOnSuccess() async throws {
		// Given
		let testImageData = UIImage.checkmark.pngData()
		let url = try #require(URL(string: "https://test-image-success.example.com/image.png"))

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
		}, forHost: "test-image-success.example.com")

		let sut = CachedImageLoader(session: .mockSession())

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result != nil)
	}

	@Test
	func imageForURLReturnsNilOnNetworkError() async throws {
		// Given
		let url = try #require(URL(string: "https://test-network-error.example.com/image.png"))

		URLProtocolMock.setHandler({ _ in
			throw URLError(.notConnectedToInternet)
		}, forHost: "test-network-error.example.com")

		let sut = CachedImageLoader(session: .mockSession())

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result == nil)
	}

	@Test
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
		}, forHost: "test-invalid-data.example.com")

		let sut = CachedImageLoader(session: .mockSession())

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result == nil)
	}

	@Test
	func imageForURLReturnsCachedImageOnSecondRequest() async throws {
		// Given
		let testImageData = UIImage.checkmark.pngData()
		let url = try #require(URL(string: "https://test-cached-second.example.com/image.png"))
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
		}, forHost: "test-cached-second.example.com")

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

	@Test
	func concurrentRequestsForSameURLAreDeduplicated() async throws {
		// Given
		let testImageData = UIImage.checkmark.pngData()
		let url = try #require(URL(string: "https://test-dedup-same.example.com/image.png"))
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
		}, forHost: "test-dedup-same.example.com")

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

	@Test
	func concurrentRequestsForDifferentURLsAreNotDeduplicated() async throws {
		// Given
		let testImageData = UIImage.checkmark.pngData()
		let url1 = try #require(URL(string: "https://test-dedup-different.example.com/image1.png"))
		let url2 = try #require(URL(string: "https://test-dedup-different.example.com/image2.png"))
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
		}, forHost: "test-dedup-different.example.com")

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

// MARK: - URL Protocol Mock

private final class URLProtocolMock: URLProtocol, @unchecked Sendable {
	nonisolated(unsafe) private static var handlers: [String: (URLRequest) throws -> (URLResponse, Data?)] = [:]
	nonisolated(unsafe) private static let lock = NSLock()

	nonisolated static func setHandler(
		_ handler: ((URLRequest) throws -> (URLResponse, Data?))?,
		forHost host: String
	) {
		lock.lock()
		defer { lock.unlock() }
		if let handler {
			handlers[host] = handler
		} else {
			handlers.removeValue(forKey: host)
		}
	}

	nonisolated private static func resolveHandler(
		for request: URLRequest
	) -> ((URLRequest) throws -> (URLResponse, Data?))? {
		lock.lock()
		defer { lock.unlock() }
		return request.url?.host.flatMap { handlers[$0] }
	}

	override nonisolated init(
		request: URLRequest,
		cachedResponse: CachedURLResponse?,
		client: (any URLProtocolClient)?
	) {
		super.init(request: request, cachedResponse: cachedResponse, client: client)
	}

	override nonisolated static func canInit(with request: URLRequest) -> Bool {
		true
	}

	override nonisolated static func canonicalRequest(for request: URLRequest) -> URLRequest {
		request
	}

	override nonisolated func startLoading() {
		guard let handler = Self.resolveHandler(for: request) else {
			client?.urlProtocol(self, didFailWithError: URLError(.badURL))
			return
		}

		do {
			let (response, data) = try handler(request)
			client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			if let data {
				client?.urlProtocol(self, didLoad: data)
			}
			client?.urlProtocolDidFinishLoading(self)
		} catch {
			client?.urlProtocol(self, didFailWithError: error)
		}
	}

	override nonisolated func stopLoading() {}
}

// MARK: - URLSession Extension

private extension URLSession {
	static func mockSession() -> URLSession {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [URLProtocolMock.self]
		return URLSession(configuration: configuration)
	}
}

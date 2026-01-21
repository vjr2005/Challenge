import Foundation
import Testing
import UIKit

@testable import ChallengeCore

struct CachedImageLoaderTests {
	// MARK: - Cached Image

	@Test
	func cachedImageForURLReturnsNilWhenNotCached() throws {
		// Given
		let sut = CachedImageLoader(session: .mockSession())
		let url = try #require(URL(string: "https://example.com/image.png"))

		// When
		let result = sut.cachedImage(for: url)

		// Then
		#expect(result == nil)
	}

	@Test
	func cachedImageForURLReturnsImageAfterLoading() async throws {
		// Given
		let testImage = createTestImage()
		let testImageData = try #require(testImage.pngData())
		let url = try #require(URL(string: "https://example.com/image.png"))

		URLProtocolMock.requestHandler = { request in
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
		}

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
		let testImage = createTestImage()
		let testImageData = try #require(testImage.pngData())
		let url = try #require(URL(string: "https://example.com/image.png"))

		URLProtocolMock.requestHandler = { request in
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
		}

		let sut = CachedImageLoader(session: .mockSession())

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result != nil)
	}

	@Test
	func imageForURLReturnsNilOnNetworkError() async throws {
		// Given
		let url = try #require(URL(string: "https://example.com/image.png"))

		URLProtocolMock.requestHandler = { _ in
			throw URLError(.notConnectedToInternet)
		}

		let sut = CachedImageLoader(session: .mockSession())

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result == nil)
	}

	@Test
	func imageForURLReturnsNilForInvalidImageData() async throws {
		// Given
		let url = try #require(URL(string: "https://example.com/image.png"))
		let invalidData = Data("not an image".utf8)

		URLProtocolMock.requestHandler = { request in
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
		}

		let sut = CachedImageLoader(session: .mockSession())

		// When
		let result = await sut.image(for: url)

		// Then
		#expect(result == nil)
	}

	@Test
	func imageForURLReturnsCachedImageOnSecondRequest() async throws {
		// Given
		let testImage = createTestImage()
		let testImageData = try #require(testImage.pngData())
		let url = try #require(URL(string: "https://example.com/image.png"))
		let requestCount = RequestCounter()

		URLProtocolMock.requestHandler = { request in
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
		}

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
		let testImage = createTestImage()
		let testImageData = try #require(testImage.pngData())
		let url = try #require(URL(string: "https://example.com/image.png"))
		let requestCount = RequestCounter()

		URLProtocolMock.requestHandler = { request in
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
		}

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
		let testImage = createTestImage()
		let testImageData = try #require(testImage.pngData())
		let url1 = try #require(URL(string: "https://example.com/image1.png"))
		let url2 = try #require(URL(string: "https://example.com/image2.png"))
		let requestCount = RequestCounter()

		URLProtocolMock.requestHandler = { request in
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
		}

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

// MARK: - Helpers

private extension CachedImageLoaderTests {
	func createTestImage() -> UIImage {
		let size = CGSize(width: 10, height: 10)
		let renderer = UIGraphicsImageRenderer(size: size)
		return renderer.image { context in
			UIColor.red.setFill()
			context.fill(CGRect(origin: .zero, size: size))
		}
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
	nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (URLResponse, Data?))?

	override nonisolated init(request: URLRequest, cachedResponse: CachedURLResponse?, client: (any URLProtocolClient)?) {
		super.init(request: request, cachedResponse: cachedResponse, client: client)
	}

	override nonisolated static func canInit(with request: URLRequest) -> Bool {
		true
	}

	override nonisolated static func canonicalRequest(for request: URLRequest) -> URLRequest {
		request
	}

	override nonisolated func startLoading() {
		guard let handler = Self.requestHandler else {
			assertionFailure("Handler not provided")
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

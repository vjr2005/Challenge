import Foundation
import Testing

@testable import ChallengeCore
@testable import ChallengeNetworking

@Suite(.timeLimit(.minutes(1)))
struct StubTransportTests {
	// MARK: - Tests

	@Test("Returns matching route response")
	func returnsMatchingRouteResponse() async throws {
		// Given
		let bodyData = Data("{\"id\":1}".utf8)
		let config = StubConfiguration(routes: [
			StubConfiguration.Route(
				pathPattern: "/api/test",
				statusCode: 200,
				bodyBase64: bodyData.base64EncodedString()
			)
		])
		let sut = StubTransport(configuration: config)
		let url = try #require(URL(string: "https://example.com/api/test"))
		let request = URLRequest(url: url)

		// When
		let (data, response) = try await sut.send(request)

		// Then
		#expect(data == bodyData)
		#expect(response.statusCode == 200)
	}

	@Test("Returns first matching route when multiple match")
	func returnsFirstMatchingRoute() async throws {
		// Given
		let firstBody = Data("{\"first\":true}".utf8)
		let secondBody = Data("{\"second\":true}".utf8)
		let config = StubConfiguration(routes: [
			StubConfiguration.Route(
				pathPattern: "/api/*",
				statusCode: 200,
				bodyBase64: firstBody.base64EncodedString()
			),
			StubConfiguration.Route(
				pathPattern: "/api/test",
				statusCode: 201,
				bodyBase64: secondBody.base64EncodedString()
			)
		])
		let sut = StubTransport(configuration: config)
		let url = try #require(URL(string: "https://example.com/api/test"))
		let request = URLRequest(url: url)

		// When
		let (data, response) = try await sut.send(request)

		// Then
		#expect(data == firstBody)
		#expect(response.statusCode == 200)
	}

	@Test("Matches wildcard pattern")
	func matchesWildcardPattern() async throws {
		// Given
		let bodyData = Data("{\"avatar\":\"data\"}".utf8)
		let config = StubConfiguration(routes: [
			StubConfiguration.Route(
				pathPattern: "/avatar/*",
				statusCode: 200,
				bodyBase64: bodyData.base64EncodedString(),
				contentType: "image/jpeg"
			)
		])
		let sut = StubTransport(configuration: config)
		let url = try #require(URL(string: "https://example.com/avatar/123.jpg"))
		let request = URLRequest(url: url)

		// When
		let (data, response) = try await sut.send(request)

		// Then
		#expect(data == bodyData)
		#expect(response.statusCode == 200)
		#expect(response.value(forHTTPHeaderField: "Content-Type") == "image/jpeg")
	}

	@Test("Matches path with query parameters")
	func matchesPathWithQueryParameters() async throws {
		// Given
		let bodyData = Data("{\"page\":2}".utf8)
		let config = StubConfiguration(routes: [
			StubConfiguration.Route(
				pathPattern: "/api/users*page=2*",
				statusCode: 200,
				bodyBase64: bodyData.base64EncodedString()
			)
		])
		let sut = StubTransport(configuration: config)
		let url = try #require(URL(string: "https://example.com/api/users?page=2&limit=10"))
		let request = URLRequest(url: url)

		// When
		let (data, response) = try await sut.send(request)

		// Then
		#expect(data == bodyData)
		#expect(response.statusCode == 200)
	}

	@Test("Throws error when no route matches")
	func throwsErrorWhenNoRouteMatches() async throws {
		// Given
		let config = StubConfiguration(routes: [
			StubConfiguration.Route(pathPattern: "/api/users")
		])
		let sut = StubTransport(configuration: config)
		let url = try #require(URL(string: "https://example.com/api/posts"))
		let request = URLRequest(url: url)

		// When / Then
		await #expect(throws: StubTransportError.self) {
			_ = try await sut.send(request)
		}
	}

	@Test("Throws error when request has no URL")
	func throwsErrorWhenRequestHasNoURL() async throws {
		// Given
		let config = StubConfiguration(routes: [])
		let sut = StubTransport(configuration: config)
		let initialURL = try #require(URL(string: "https://example.com"))
		var request = URLRequest(url: initialURL)
		request.url = nil

		// When / Then
		await #expect(throws: StubTransportError.invalidRequest) {
			_ = try await sut.send(request)
		}
	}

	@Test("Returns configured status code for error responses")
	func returnsConfiguredStatusCodeForErrors() async throws {
		// Given
		let errorBody = Data("{\"error\":\"Not found\"}".utf8)
		let config = StubConfiguration(routes: [
			StubConfiguration.Route(
				pathPattern: "/api/missing",
				statusCode: 404,
				bodyBase64: errorBody.base64EncodedString()
			)
		])
		let sut = StubTransport(configuration: config)
		let url = try #require(URL(string: "https://example.com/api/missing"))
		let request = URLRequest(url: url)

		// When
		let (data, response) = try await sut.send(request)

		// Then
		#expect(data == errorBody)
		#expect(response.statusCode == 404)
	}
}

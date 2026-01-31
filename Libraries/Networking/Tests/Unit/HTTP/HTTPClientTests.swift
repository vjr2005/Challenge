import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeNetworking

@Suite(.timeLimit(.minutes(1)))
struct HTTPClientTests {
	@Test
	func buildsCorrectURLFromEndpoint() async throws {
		// Given
		let baseURL = try #require(URL(string: "https://test-builds-url.example.com"))
		let session = URLSession.mockSession()
		let sut = HTTPClient(baseURL: baseURL, session: session)
		let endpoint = Endpoint(path: "/users")

		URLProtocolMock.setHandler({ request in
			// Then
			#expect(request.url?.absoluteString == "\(baseURL)/users")
			#expect(request.httpMethod == "GET")
			return (mockResponse(url: request.url), Data())
		}, forURL: baseURL)

		// When
		_ = try await sut.request(endpoint)
	}

	@Test
	func includesQueryItemsInURL() async throws {
		// Given
		let baseURL = try #require(URL(string: "https://test-query-items.example.com"))
		let session = URLSession.mockSession()
		let sut = HTTPClient(baseURL: baseURL, session: session)
		let endpoint = Endpoint(
			path: "/users",
			queryItems: [
				URLQueryItem(name: "page", value: "1"),
				URLQueryItem(name: "limit", value: "20")
			]
		)

		URLProtocolMock.setHandler({ request in
			// Then
			let urlString = request.url?.absoluteString ?? ""
			#expect(urlString.contains("page=1"))
			#expect(urlString.contains("limit=20"))
			return (mockResponse(url: request.url), Data())
		}, forURL: baseURL)

		// When
		_ = try await sut.request(endpoint)
	}

	@Test
	func includesHeadersInRequest() async throws {
		// Given
		let baseURL = try #require(URL(string: "https://test-headers.example.com"))
		let session = URLSession.mockSession()
		let sut = HTTPClient(baseURL: baseURL, session: session)
		let endpoint = Endpoint(
			path: "/users",
			headers: [
				"Authorization": "Bearer token123",
				"Content-Type": "application/json"
			]
		)

		URLProtocolMock.setHandler({ request in
			// Then
			#expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token123")
			#expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
			return (mockResponse(url: request.url), Data())
		}, forURL: baseURL)

		// When
		_ = try await sut.request(endpoint)
	}

	@Test
	func includesBodyInRequest() async throws {
		// Given
		let baseURL = try #require(URL(string: "https://test-body.example.com"))
		let session = URLSession.mockSession()
		let sut = HTTPClient(baseURL: baseURL, session: session)
		let body = Data("{\"name\":\"test\"}".utf8)
		let endpoint = Endpoint(
			path: "/users",
			method: .post,
			body: body
		)

		URLProtocolMock.setHandler({ request in
			// Then
			#expect(request.httpMethod == "POST")
			#expect(request.bodyData == body)
			return (mockResponse(url: request.url), Data())
		}, forURL: baseURL)

		// When
		_ = try await sut.request(endpoint)
	}

	@Test
	func returnsDataOnSuccess() async throws {
		// Given
		let baseURL = try #require(URL(string: "https://test-returns-data.example.com"))
		let session = URLSession.mockSession()
		let sut = HTTPClient(baseURL: baseURL, session: session)
		let expectedData = Data("{\"id\":1}".utf8)

		URLProtocolMock.setHandler({ request in
			(mockResponse(url: request.url ?? baseURL), expectedData)
		}, forURL: baseURL)

		// When
		let data = try await sut.request(Endpoint(path: "/users"))

		// Then
		#expect(data == expectedData)
	}

	@Test
	func decodesResponseToType() async throws {
		// Given
		let baseURL = try #require(URL(string: "https://test-decodes-response.example.com"))
		let session = URLSession.mockSession()
		let sut = HTTPClient(baseURL: baseURL, session: session)
		let responseData = Data("{\"id\":1,\"name\":\"John\"}".utf8)

		URLProtocolMock.setHandler({ request in
			(mockResponse(url: request.url ?? baseURL), responseData)
		}, forURL: baseURL)

		// When
		let user: TestUser = try await sut.request(Endpoint(path: "/users/1"))

		// Then
		#expect(user.id == 1)
		#expect(user.name == "John")
	}

	@Test(arguments: [400, 401, 403, 404, 500, 502, 503])
	func throwsStatusCodeErrorForHTTPErrors(_ statusCode: Int) async throws {
		// Given
		let baseURL = try #require(URL(string: "https://test-status-\(statusCode).example.com"))
		let session = URLSession.mockSession()
		let sut = HTTPClient(baseURL: baseURL, session: session)
		let errorData = Data("Error".utf8)

		URLProtocolMock.setHandler({ request in
			(mockResponse(url: request.url ?? baseURL, statusCode: statusCode), errorData)
		}, forURL: baseURL)

		// When / Then
		await #expect(throws: HTTPError.statusCode(statusCode, errorData)) {
			_ = try await sut.request(Endpoint(path: "/error"))
		}
	}

	@Test
	func throwsInvalidResponseWhenResponseIsNotHTTPURLResponse() async throws {
		// Given
		// Use custom URL scheme to prevent URLSession from auto-converting to HTTPURLResponse
		let baseURL = try #require(URL(string: "custom://test-invalid-response.example.com"))
		let session = URLSession.mockSession()
		let sut = HTTPClient(baseURL: baseURL, session: session)

		URLProtocolMock.setHandler({ request in
			let response = URLResponse(
				url: request.url ?? baseURL,
				mimeType: nil,
				expectedContentLength: 0,
				textEncodingName: nil
			)
			return (response, Data())
		}, forURL: baseURL)

		// When / Then
		await #expect(throws: HTTPError.invalidResponse) {
			_ = try await sut.request(Endpoint(path: "/test"))
		}
	}
}

private struct TestUser: Decodable {
	let id: Int
	let name: String
}

private extension HTTPClientTests {
	func mockResponse(url: URL?, statusCode: Int = 200) -> HTTPURLResponse {
		guard let url,
			let response = HTTPURLResponse.withStatus(statusCode, url: url)
		else {
			preconditionFailure("Failed to create HTTPURLResponse with status \(statusCode)")
		}
		return response
	}
}

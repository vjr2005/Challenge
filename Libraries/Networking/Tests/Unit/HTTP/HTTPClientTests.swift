import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import ChallengeNetworking

@Suite(.timeLimit(.minutes(1)))
struct HTTPClientTests {
	// MARK: - Properties

	private let baseURL: URL
	private let transport: HTTPTransportMock
	private let sut: HTTPClient

	// MARK: - Initialization

	init() throws {
		baseURL = try #require(URL(string: "https://test.example.com"))
		transport = HTTPTransportMock()
		sut = HTTPClient(baseURL: baseURL, transport: transport)
	}

	// MARK: - Tests

	@Test("Builds correct URL from base URL and endpoint path")
	func buildsCorrectURLFromEndpoint() async throws {
		// Given
		let endpoint = Endpoint(path: "/users")
		await transport.setResult(.success((Data(), Self.mockResponse(url: baseURL))))

		// When
		_ = try await sut.request(endpoint)

		// Then
		let sentRequests = await transport.sentRequests
		#expect(sentRequests.count == 1)
		#expect(sentRequests[0].url?.absoluteString == "\(baseURL)/users")
		#expect(sentRequests[0].httpMethod == "GET")
	}

	@Test("Includes query items in URL when provided")
	func includesQueryItemsInURL() async throws {
		// Given
		let endpoint = Endpoint(
			path: "/users",
			queryItems: [
				URLQueryItem(name: "page", value: "1"),
				URLQueryItem(name: "limit", value: "20")
			]
		)
		await transport.setResult(.success((Data(), Self.mockResponse(url: baseURL))))

		// When
		_ = try await sut.request(endpoint)

		// Then
		let sentRequests = await transport.sentRequests
		#expect(sentRequests.count == 1)
		let urlString = sentRequests[0].url?.absoluteString ?? ""
		#expect(urlString.contains("page=1"))
		#expect(urlString.contains("limit=20"))
	}

	@Test("Includes headers in request when provided")
	func includesHeadersInRequest() async throws {
		// Given
		let endpoint = Endpoint(
			path: "/users",
			headers: [
				"Authorization": "Bearer token123",
				"Content-Type": "application/json"
			]
		)
		await transport.setResult(.success((Data(), Self.mockResponse(url: baseURL))))

		// When
		_ = try await sut.request(endpoint)

		// Then
		let sentRequests = await transport.sentRequests
		#expect(sentRequests.count == 1)
		#expect(sentRequests[0].value(forHTTPHeaderField: "Authorization") == "Bearer token123")
		#expect(sentRequests[0].value(forHTTPHeaderField: "Content-Type") == "application/json")
	}

	@Test("Includes body in POST request when provided")
	func includesBodyInRequest() async throws {
		// Given
		let body = Data("{\"name\":\"test\"}".utf8)
		let endpoint = Endpoint(
			path: "/users",
			method: .post,
			body: body
		)
		await transport.setResult(.success((Data(), Self.mockResponse(url: baseURL))))

		// When
		_ = try await sut.request(endpoint)

		// Then
		let sentRequests = await transport.sentRequests
		#expect(sentRequests.count == 1)
		#expect(sentRequests[0].httpMethod == "POST")
		#expect(sentRequests[0].httpBody == body)
	}

	@Test("Returns data on successful response")
	func returnsDataOnSuccess() async throws {
		// Given
		let expectedData = Data("{\"id\":1}".utf8)
		await transport.setResult(.success((expectedData, Self.mockResponse(url: baseURL))))

		// When
		let data = try await sut.request(Endpoint(path: "/users"))

		// Then
		#expect(data == expectedData)
	}

	@Test("Decodes JSON response to specified type")
	func decodesResponseToType() async throws {
		// Given
		let responseData = Data("{\"id\":1,\"name\":\"John\"}".utf8)
		await transport.setResult(.success((responseData, Self.mockResponse(url: baseURL))))

		// When
		let user: TestUser = try await sut.request(Endpoint(path: "/users/1"))

		// Then
		#expect(user.id == 1)
		#expect(user.name == "John")
	}

	@Test(arguments: [400, 401, 403, 404, 500, 502, 503])
	func throwsStatusCodeErrorForHTTPErrors(_ statusCode: Int) async throws {
		// Given
		let errorData = Data("Error".utf8)
		await transport.setResult(.success((errorData, Self.mockResponse(url: baseURL, statusCode: statusCode))))

		// When / Then
		await #expect(throws: HTTPError.statusCode(statusCode, errorData)) {
			_ = try await sut.request(Endpoint(path: "/error"))
		}
	}
}

// MARK: - Private

private struct TestUser: Decodable {
	let id: Int
	let name: String
}

private extension HTTPClientTests {
	static func mockResponse(url: URL, statusCode: Int = 200) -> HTTPURLResponse {
		guard let response = HTTPURLResponse(
			url: url,
			statusCode: statusCode,
			httpVersion: "HTTP/1.1",
			headerFields: nil
		) else {
			preconditionFailure("Failed to create HTTPURLResponse with status \(statusCode)")
		}
		return response
	}
}

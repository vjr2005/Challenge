import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import ChallengeNetworking

@Suite(.timeLimit(.minutes(1)))
struct GraphQLClientTests {
	// MARK: - Properties

	private let httpClientMock = HTTPClientMock()
	private let sut: GraphQLClient

	// MARK: - Init

	init() {
		sut = GraphQLClient(httpClient: httpClientMock)
	}

	// MARK: - Endpoint Tests

	@Test("Sends POST request to /graphql path")
	func sendsPostToGraphQLPath() async throws {
		// Given
		let operation = GraphQLOperation(query: "{ episodes { results { id } } }")
		httpClientMock.result = .success(try makeEnvelopeData(["episodes": ["results": []]]))

		// When
		let _: TestResponse = try await sut.execute(operation)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		#expect(endpoint.path == "/graphql")
		#expect(endpoint.method == .post)
	}

	@Test("Sends POST request to custom path when configured")
	func sendsPostToCustomPath() async throws {
		// Given
		let customSut = GraphQLClient(httpClient: httpClientMock, path: "/api/graphql")
		let operation = GraphQLOperation(query: "{ episodes { results { id } } }")
		httpClientMock.result = .success(try makeEnvelopeData(["episodes": ["results": []]]))

		// When
		let _: TestResponse = try await customSut.execute(operation)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		#expect(endpoint.path == "/api/graphql")
	}

	@Test("Sets Content-Type header to application/json")
	func setsContentTypeHeader() async throws {
		// Given
		let operation = GraphQLOperation(query: "{ episodes { results { id } } }")
		httpClientMock.result = .success(try makeEnvelopeData(["episodes": ["results": []]]))

		// When
		let _: TestResponse = try await sut.execute(operation)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		#expect(endpoint.headers["Content-Type"] == "application/json")
	}

	// MARK: - Body Encoding Tests

	@Test("Encodes query in request body")
	func encodesQueryInBody() async throws {
		// Given
		let query = "{ episodes { results { id name } } }"
		let operation = GraphQLOperation(query: query)
		httpClientMock.result = .success(try makeEnvelopeData(["episodes": ["results": []]]))

		// When
		let _: TestResponse = try await sut.execute(operation)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let body = try #require(endpoint.body)
		let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
		#expect(json["query"] as? String == query)
	}

	@Test("Encodes variables in request body when provided")
	func encodesVariablesInBody() async throws {
		// Given
		let operation = GraphQLOperation(
			query: "query ($page: Int!) { episodes(page: $page) { results { id } } }",
			variables: ["page": .int(2)]
		)
		httpClientMock.result = .success(try makeEnvelopeData(["episodes": ["results": []]]))

		// When
		let _: TestResponse = try await sut.execute(operation)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let body = try #require(endpoint.body)
		let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
		let variables = try #require(json["variables"] as? [String: Any])
		#expect(variables["page"] as? Int == 2)
	}

	@Test("Omits variables from body when nil")
	func omitsVariablesWhenNil() async throws {
		// Given
		let operation = GraphQLOperation(query: "{ episodes { results { id } } }")
		httpClientMock.result = .success(try makeEnvelopeData(["episodes": ["results": []]]))

		// When
		let _: TestResponse = try await sut.execute(operation)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let body = try #require(endpoint.body)
		let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
		#expect(json["variables"] == nil)
	}

	@Test("Encodes operation name in body when provided")
	func encodesOperationNameInBody() async throws {
		// Given
		let operation = GraphQLOperation(
			query: "query GetEpisodes { episodes { results { id } } }",
			operationName: "GetEpisodes"
		)
		httpClientMock.result = .success(try makeEnvelopeData(["episodes": ["results": []]]))

		// When
		let _: TestResponse = try await sut.execute(operation)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let body = try #require(endpoint.body)
		let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
		#expect(json["operationName"] as? String == "GetEpisodes")
	}

	@Test("Omits operation name from body when nil")
	func omitsOperationNameWhenNil() async throws {
		// Given
		let operation = GraphQLOperation(query: "{ episodes { results { id } } }")
		httpClientMock.result = .success(try makeEnvelopeData(["episodes": ["results": []]]))

		// When
		let _: TestResponse = try await sut.execute(operation)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		let body = try #require(endpoint.body)
		let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
		#expect(json["operationName"] == nil)
	}

	// MARK: - Envelope Unwrapping Tests

	@Test("Unwraps data payload from envelope")
	func unwrapsDataFromEnvelope() async throws {
		// Given
		let operation = GraphQLOperation(query: "{ episodes { results { id } } }")
		let payload: [String: Any] = ["episodes": ["results": [["id": "1", "name": "Pilot"]]]]
		httpClientMock.result = .success(try makeEnvelopeData(payload))

		// When
		let result: TestEpisodesWrapper = try await sut.execute(operation)

		// Then
		#expect(result.episodes.results.count == 1)
		#expect(result.episodes.results.first?.id == "1")
		#expect(result.episodes.results.first?.name == "Pilot")
	}

	// MARK: - Error Mapping Tests

	@Test("Maps GraphQL errors to APIError.invalidResponse")
	func mapsGraphQLErrorsToInvalidResponse() async throws {
		// Given
		let operation = GraphQLOperation(query: "{ invalid }")
		let errorResponse: [String: Any] = [
			"errors": [
				["message": "Cannot query field \"invalid\"", "locations": [["line": 1, "column": 3]]]
			]
		]
		httpClientMock.result = .success(try JSONSerialization.data(withJSONObject: errorResponse))

		// When / Then
		await #expect(throws: APIError.invalidResponse) {
			let _: TestResponse = try await sut.execute(operation)
		}
	}

	@Test("Maps multiple GraphQL errors to APIError.invalidResponse")
	func mapsMultipleGraphQLErrorsToInvalidResponse() async throws {
		// Given
		let operation = GraphQLOperation(query: "{ a b }")
		let errorResponse: [String: Any] = [
			"errors": [
				["message": "Error 1"],
				["message": "Error 2"]
			]
		]
		httpClientMock.result = .success(try JSONSerialization.data(withJSONObject: errorResponse))

		// When / Then
		await #expect(throws: APIError.invalidResponse) {
			let _: TestResponse = try await sut.execute(operation)
		}
	}

	@Test("Maps HTTP 404 error to APIError.notFound")
	func mapsHTTPNotFoundError() async throws {
		// Given
		let operation = GraphQLOperation(query: "{ episodes { results { id } } }")
		httpClientMock.result = .failure(HTTPError.statusCode(404, Data()))

		// When / Then
		await #expect(throws: APIError.notFound) {
			let _: TestResponse = try await sut.execute(operation)
		}
	}

	@Test("Maps HTTP 500 error to APIError.serverError")
	func mapsHTTPServerError() async throws {
		// Given
		let operation = GraphQLOperation(query: "{ episodes { results { id } } }")
		httpClientMock.result = .failure(HTTPError.statusCode(500, Data()))

		// When / Then
		await #expect(throws: APIError.serverError(statusCode: 500)) {
			let _: TestResponse = try await sut.execute(operation)
		}
	}

	@Test("Maps invalid response to APIError.invalidResponse")
	func mapsInvalidResponseToAPIError() async throws {
		// Given
		let operation = GraphQLOperation(query: "{ episodes { results { id } } }")
		let emptyEnvelope: [String: Any] = ["data": NSNull()]
		httpClientMock.result = .success(try JSONSerialization.data(withJSONObject: emptyEnvelope))

		// When / Then
		await #expect(throws: APIError.invalidResponse) {
			let _: TestResponse = try await sut.execute(operation)
		}
	}

	@Test("Maps invalid JSON to APIError.decodingFailed")
	func mapsInvalidJSONToDecodingFailed() async throws {
		// Given
		let operation = GraphQLOperation(query: "{ episodes { results { id } } }")
		httpClientMock.result = .success(Data("not json".utf8))

		// When / Then
		await #expect {
			let _: TestResponse = try await sut.execute(operation)
		} throws: { error in
			guard let apiError = error as? APIError,
				  case .decodingFailed = apiError else {
				return false
			}
			return true
		}
	}
}

// MARK: - Test Helpers

private struct TestResponse: Decodable {
	let episodes: TestEpisodesList
}

private struct TestEpisodesWrapper: Decodable {
	let episodes: TestEpisodesList
}

private struct TestEpisodesList: Decodable {
	let results: [TestEpisode]
}

private struct TestEpisode: Decodable {
	let id: String
	let name: String
}

private extension GraphQLClientTests {
	func makeEnvelopeData(_ data: [String: Any]) throws -> Data {
		let envelope: [String: Any] = ["data": data]
		return try JSONSerialization.data(withJSONObject: envelope)
	}
}

import Foundation

/// GraphQL client that composes on top of HTTPClientContract.
public struct GraphQLClient: GraphQLClientContract {
	private let httpClient: any HTTPClientContract
	private let path: String
	private let encoder: JSONEncoder
	private let decoder: JSONDecoder

	/// Creates a new GraphQL client.
	/// - Parameters:
	///   - httpClient: The HTTP client to use for requests.
	///   - path: The GraphQL endpoint path. Defaults to `/graphql`.
	///   - encoder: The JSON encoder. Defaults to a new `JSONEncoder`.
	///   - decoder: The JSON decoder. Defaults to a new `JSONDecoder`.
	public init(
		httpClient: any HTTPClientContract,
		path: String = "/graphql",
		encoder: JSONEncoder = JSONEncoder(),
		decoder: JSONDecoder = JSONDecoder()
	) {
		self.httpClient = httpClient
		self.path = path
		self.encoder = encoder
		self.decoder = decoder
	}

	/// Executes a GraphQL operation and decodes the data payload.
	public func execute<T: Decodable>(_ operation: GraphQLOperation) async throws -> T {
		let body = try encodeBody(operation)
		let endpoint = Endpoint(
			path: path,
			method: .post,
			headers: ["Content-Type": "application/json"],
			body: body
		)

		let data: Data
		do {
			data = try await httpClient.request(endpoint)
		} catch let error as HTTPError {
			throw mapHTTPError(error)
		}

		let envelope = try decodeEnvelope(T.self, from: data)

		if let errors = envelope.errors, !errors.isEmpty {
			throw GraphQLError.response(errors)
		}

		guard let payload = envelope.data else {
			throw GraphQLError.invalidResponse
		}

		return payload
	}
}

// MARK: - Private

private extension GraphQLClient {
	func encodeBody(_ operation: GraphQLOperation) throws -> Data {
		var body: [String: Any] = ["query": operation.query]

		if let variables = operation.variables {
			let variablesData = try encoder.encode(variables)
			body["variables"] = try JSONSerialization.jsonObject(with: variablesData)
		}

		if let operationName = operation.operationName {
			body["operationName"] = operationName
		}

		return try JSONSerialization.data(withJSONObject: body)
	}

	func decodeEnvelope<T: Decodable>(_ type: T.Type, from data: Data) throws -> GraphQLResponse<T> {
		do {
			return try decoder.decode(GraphQLResponse<T>.self, from: data)
		} catch {
			throw GraphQLError.decodingFailed(description: String(describing: error))
		}
	}

	func mapHTTPError(_ error: HTTPError) -> GraphQLError {
		switch error {
		case let .statusCode(code, data):
			.statusCode(code, data)
		case .invalidURL, .invalidResponse:
			.invalidResponse
		}
	}
}

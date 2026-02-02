import Foundation

/// Represents a single stubbed endpoint configuration for UI tests.
nonisolated public struct EndpointStub: Codable, Sendable, Equatable {
	/// The path pattern to match (e.g., "/character", "/avatar/*").
	public let pathPattern: String
	/// The HTTP method to match. Defaults to "GET".
	public let method: String
	/// The HTTP status code to return. Defaults to 200.
	public let statusCode: Int
	/// The response body as a string (JSON or plain text).
	public let responseBody: String
	/// The Content-Type header value. Defaults to "application/json".
	public let contentType: String
	/// Whether the responseBody is Base64 encoded (for binary data like images).
	public let isBase64Encoded: Bool
	/// Optional delay in seconds before returning the response.
	public let delay: TimeInterval?

	public init(
		pathPattern: String,
		method: String = "GET",
		statusCode: Int = 200,
		responseBody: String,
		contentType: String = "application/json",
		isBase64Encoded: Bool = false,
		delay: TimeInterval? = nil
	) {
		self.pathPattern = pathPattern
		self.method = method
		self.statusCode = statusCode
		self.responseBody = responseBody
		self.contentType = contentType
		self.isBase64Encoded = isBase64Encoded
		self.delay = delay
	}
}

/// Configuration for stubbing HTTP requests during UI tests.
nonisolated public struct StubConfiguration: Codable, Sendable, Equatable {
	/// The base URL that will be intercepted (e.g., "https://rickandmortyapi.com/api").
	public let baseURL: String
	/// The list of endpoint configurations.
	public let endpoints: [EndpointStub]
	/// Optional default response for unmatched requests.
	public let defaultResponse: EndpointStub?

	public init(
		baseURL: String,
		endpoints: [EndpointStub],
		defaultResponse: EndpointStub? = nil
	) {
		self.baseURL = baseURL
		self.endpoints = endpoints
		self.defaultResponse = defaultResponse
	}
}

import Foundation

/// Represents an API endpoint configuration.
public struct Endpoint {
	public let path: String
	public let method: HTTPMethod
	public let headers: [String: String]
	public let queryItems: [URLQueryItem]?
	public let body: Data?

	public init(
		path: String,
		method: HTTPMethod = .get,
		headers: [String: String] = [:],
		queryItems: [URLQueryItem]? = nil,
		body: Data? = nil,
	) {
		self.path = path
		self.method = method
		self.headers = headers
		self.queryItems = queryItems
		self.body = body
	}
}

import Foundation

/// Represents an API endpoint configuration.
public struct Endpoint {
	/// The URL path component of the endpoint.
	public let path: String
	/// The HTTP method for the request.
	public let method: HTTPMethod
	/// The HTTP headers to include in the request.
	public let headers: [String: String]
	/// The URL query items to append to the request URL.
	public let queryItems: [URLQueryItem]?
	/// The HTTP body data for the request.
	public let body: Data?

	/// Creates a new endpoint configuration.
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

import Foundation

/// Contract for HTTP client implementations.
public protocol HTTPClientContract: Sendable {
	/// Performs a request and decodes the response to the specified type.
	@concurrent func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T

	/// Performs a request and returns raw data.
	@concurrent func request(_ endpoint: Endpoint) async throws -> Data
}

import Foundation

/// Contract for HTTP client implementations.
public protocol HTTPClientContract: Sendable {
	/// Performs a request and decodes the response to the specified type.
	func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T

	/// Performs a request and returns raw data.
	func request(_ endpoint: Endpoint) async throws -> Data
}

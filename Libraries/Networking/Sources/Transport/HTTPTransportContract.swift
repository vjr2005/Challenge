import Foundation

/// Abstraction for HTTP transport following Quinn's proposal.
/// Minimal interface: URLRequest -> (Data, HTTPURLResponse)
/// Sendable because all implementations must be thread-safe.
public protocol HTTPTransportContract: Sendable {
	func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

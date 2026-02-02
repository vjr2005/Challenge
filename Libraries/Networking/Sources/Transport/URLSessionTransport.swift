import Foundation

/// Production implementation of HTTPTransportContract using URLSession.
/// nonisolated because URLSession.data is async and can execute in any context.
nonisolated public struct URLSessionTransport: HTTPTransportContract {
	private let session: URLSession

	public init(session: URLSession = .shared) {
		self.session = session
	}

	public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
		let (data, response) = try await session.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else {
			throw HTTPTransportError.invalidResponse
		}
		return (data, httpResponse)
	}
}

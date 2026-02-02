import ChallengeNetworking
import Foundation

/// Mock of HTTPTransportContract for unit tests.
/// Uses actor for thread-safety when tests run in parallel.
/// IMPORTANT: Each test must create its own instance.
public actor HTTPTransportMock: HTTPTransportContract {
	public var result: Result<(Data, HTTPURLResponse), Error> = .success((Data(), HTTPURLResponse()))
	public private(set) var sentRequests: [URLRequest] = []

	public init() {}

	nonisolated public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
		await appendRequest(request)
		return try await getResult()
	}

	/// Configures the result to return (for use from tests).
	public func setResult(_ result: Result<(Data, HTTPURLResponse), Error>) {
		self.result = result
	}

	private func appendRequest(_ request: URLRequest) {
		sentRequests.append(request)
	}

	private func getResult() throws -> (Data, HTTPURLResponse) {
		try result.get()
	}
}

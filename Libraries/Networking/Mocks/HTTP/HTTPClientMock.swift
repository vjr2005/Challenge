import ChallengeNetworking
import Foundation

/// Mock implementation of HTTPClientContract for testing.
public final class HTTPClientMock: HTTPClientContract, @unchecked Sendable {
	public private(set) var requestedEndpoints: [Endpoint] = []

	private let result: Result<Data, Error>

	public init(result: Result<Data, Error> = .success(Data())) {
		self.result = result
	}

	public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
		requestedEndpoints.append(endpoint)
		let data = try result.get()
		return try JSONDecoder().decode(T.self, from: data)
	}

	public func request(_ endpoint: Endpoint) async throws -> Data {
		requestedEndpoints.append(endpoint)
		return try result.get()
	}
}

import ChallengeNetworking
import Foundation

/// Mock implementation of HTTPClientContract for testing.
public final class HTTPClientMock: HTTPClientContract, @unchecked Sendable {
	/// The endpoints that have been requested.
	public private(set) var requestedEndpoints: [Endpoint] = []

	private let result: Result<Data, Error>

	/// Creates a new HTTP client mock with the given result.
	public init(result: Result<Data, Error> = .success(Data())) {
		self.result = result
	}

	/// Records the endpoint and returns the mock result decoded as the specified type.
	public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
		requestedEndpoints.append(endpoint)
		let data = try result.get()
		return try JSONDecoder().decode(T.self, from: data)
	}

	/// Records the endpoint and returns the mock result as raw data.
	public func request(_ endpoint: Endpoint) async throws -> Data {
		requestedEndpoints.append(endpoint)
		return try result.get()
	}
}

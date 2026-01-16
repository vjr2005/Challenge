import Foundation

/// HTTP client implementation using URLSession with async/await.
open class HTTPClient: HTTPClientContract {
	private let session: URLSession
	private let baseURL: URL
	private let decoder: JSONDecoder

	public init(
		baseURL: URL,
		session: URLSession = .shared,
		decoder: JSONDecoder = JSONDecoder()
	) {
		self.baseURL = baseURL
		self.session = session
		self.decoder = decoder
	}

	public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
		let data = try await request(endpoint)
		return try decoder.decode(T.self, from: data)
	}

	public func request(_ endpoint: Endpoint) async throws -> Data {
		let request = try buildRequest(for: endpoint)
		let (data, response) = try await session.data(for: request)

		guard let httpResponse = response as? HTTPURLResponse else {
			throw HTTPError.invalidResponse
		}

		guard (200...299).contains(httpResponse.statusCode) else {
			throw HTTPError.statusCode(httpResponse.statusCode, data)
		}

		return data
	}
}

// MARK: - Private

private extension HTTPClient {
	func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
		var components = URLComponents(
			url: baseURL.appendingPathComponent(endpoint.path),
			resolvingAgainstBaseURL: true,
		)
		components?.queryItems = endpoint.queryItems

		// Defensive check: URLComponents.url can return nil in edge cases
		// that are difficult to reproduce (e.g., invalid percent encoding).
		// In practice, appendingPathComponent always produces valid URLs.
		guard let url = components?.url else {
			throw HTTPError.invalidURL
		}

		var request = URLRequest(url: url)
		request.httpMethod = endpoint.method.rawValue
		request.httpBody = endpoint.body

		for (key, value) in endpoint.headers {
			request.setValue(value, forHTTPHeaderField: key)
		}

		return request
	}
}

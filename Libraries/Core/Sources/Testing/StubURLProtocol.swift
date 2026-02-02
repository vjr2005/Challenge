import Foundation

/// A custom URLProtocol that intercepts requests and returns stubbed responses.
/// Used during UI testing to avoid network calls.
/// Note: Uses nonisolated(unsafe) for static configuration as URLProtocol requires nonisolated methods.
nonisolated public final class StubURLProtocol: URLProtocol, @unchecked Sendable {
	/// The stub configuration loaded from the environment.
	nonisolated(unsafe) private static var configuration: StubConfiguration?

	/// Registers the protocol and loads the stub configuration from the environment.
	public static func registerIfNeeded() {
		guard let configPath = ProcessInfo.processInfo.environment[StubEnvironment.configPathKey] else {
			return
		}

		guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath)),
			  let config = try? JSONDecoder().decode(StubConfiguration.self, from: data) else {
			print("StubURLProtocol: Failed to load configuration from \(configPath)")
			return
		}

		configuration = config
		URLProtocol.registerClass(StubURLProtocol.self)
	}

	/// Returns whether this protocol can handle the given request.
	override public static func canInit(with request: URLRequest) -> Bool {
		configuration != nil
	}

	/// Returns the canonical version of the request.
	override public static func canonicalRequest(for request: URLRequest) -> URLRequest {
		request
	}

	/// Starts loading the request by returning a stubbed response.
	override public func startLoading() {
		guard let url = request.url,
			  let configuration = Self.configuration else {
			client?.urlProtocol(self, didFailWithError: URLError(.badURL))
			return
		}

		let response = findMatchingResponse(for: url, in: configuration)
		deliverResponse(response, for: url)
	}

	/// Stops loading (no-op since responses are delivered synchronously).
	override public func stopLoading() {}
}

// MARK: - Private

nonisolated private extension StubURLProtocol {
	func findMatchingResponse(for url: URL, in configuration: StubConfiguration) -> EndpointStub? {
		guard let baseURL = URL(string: configuration.baseURL) else {
			return configuration.defaultResponse
		}

		// Get the path and query from the URL
		let urlString = url.absoluteString
		let basePath = baseURL.absoluteString

		// Check if this URL is for our base URL
		guard urlString.hasPrefix(basePath) else {
			return configuration.defaultResponse
		}

		// Get the relative path including query
		let relativePath = String(urlString.dropFirst(basePath.count))
		let pathWithQuery = relativePath.hasPrefix("/") ? relativePath : "/\(relativePath)"

		// Find matching endpoint (first match wins)
		for endpoint in configuration.endpoints where matchesPattern(path: pathWithQuery, pattern: endpoint.pathPattern) {
			return endpoint
		}

		return configuration.defaultResponse
	}

	func matchesPattern(path: String, pattern: String) -> Bool {
		// Split into path and query components
		let pathComponents = path.components(separatedBy: "?")
		let patternComponents = pattern.components(separatedBy: "?")

		let pathOnly = pathComponents.first ?? path
		let patternPathOnly = patternComponents.first ?? pattern

		// Handle wildcard patterns (e.g., "/avatar/*")
		if patternPathOnly.contains("*") {
			let patternParts = patternPathOnly.split(separator: "*", omittingEmptySubsequences: false)
			if patternParts.count == 2 {
				let prefix = String(patternParts[0])
				let suffix = String(patternParts[1])
				if pathOnly.hasPrefix(prefix) && pathOnly.hasSuffix(suffix) {
					return true
				}
			}
			return false
		}

		// Path must match exactly (ignoring query string for path comparison)
		guard pathOnly == patternPathOnly else {
			return false
		}

		// If pattern has no query params, match any request to that path
		guard patternComponents.count > 1, let patternQuery = patternComponents.last, !patternQuery.isEmpty else {
			return true
		}

		// If pattern has query params, check that they are present in the request
		guard pathComponents.count > 1, let pathQuery = pathComponents.last else {
			return false
		}

		// Parse query params from both
		let pathParams = parseQueryParams(pathQuery)
		let patternParams = parseQueryParams(patternQuery)

		// All pattern params must be present in path params with same values
		for (key, value) in patternParams {
			guard pathParams[key] == value else {
				return false
			}
		}

		return true
	}

	func parseQueryParams(_ query: String) -> [String: String] {
		var params: [String: String] = [:]
		let pairs = query.components(separatedBy: "&")
		for pair in pairs {
			let keyValue = pair.components(separatedBy: "=")
			if keyValue.count == 2 {
				params[keyValue[0]] = keyValue[1]
			}
		}
		return params
	}

	func deliverResponse(_ endpoint: EndpointStub?, for url: URL) {
		guard let endpoint else {
			let response = HTTPURLResponse(
				url: url,
				statusCode: 404,
				httpVersion: "HTTP/1.1",
				headerFields: ["Content-Type": "application/json"]
			)
			let data = Data("{\"error\": \"Not Found\"}".utf8)

			if let response {
				client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			}
			client?.urlProtocol(self, didLoad: data)
			client?.urlProtocolDidFinishLoading(self)
			return
		}

		let data: Data
		if endpoint.isBase64Encoded {
			data = Data(base64Encoded: endpoint.responseBody) ?? Data()
		} else {
			data = Data(endpoint.responseBody.utf8)
		}

		let response = HTTPURLResponse(
			url: url,
			statusCode: endpoint.statusCode,
			httpVersion: "HTTP/1.1",
			headerFields: ["Content-Type": endpoint.contentType]
		)

		if let response {
			client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
		}
		client?.urlProtocol(self, didLoad: data)
		client?.urlProtocolDidFinishLoading(self)
	}
}

// MARK: - StubEnvironment

/// Environment keys for stub configuration.
nonisolated public enum StubEnvironment: Sendable {
	/// Environment variable key for the stub configuration file path.
	public static let configPathKey = "STUB_CONFIG_PATH"

	/// Returns true if running with stub configuration.
	public static var isEnabled: Bool {
		ProcessInfo.processInfo.environment[configPathKey] != nil
	}
}

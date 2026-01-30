import Foundation

final class URLProtocolMock: URLProtocol, @unchecked Sendable {
	nonisolated(unsafe) private static var handlers: [String: (URLRequest) throws -> (URLResponse, Data?)] = [:]
	nonisolated(unsafe) private static let lock = NSLock()

	/// Legacy support - default handler for tests that don't use host-specific handlers.
	nonisolated static var requestHandler: ((URLRequest) throws -> (URLResponse, Data?))? {
		get { handler(forHost: "default") }
		set { setHandler(newValue, forHost: "default") }
	}

	/// Registers a handler for a specific host.
	/// - Parameters:
	///   - handler: The handler to invoke for requests to this host. Pass nil to remove.
	///   - host: The host string (e.g., "api.example.com").
	nonisolated static func setHandler(
		_ handler: ((URLRequest) throws -> (URLResponse, Data?))?,
		forHost host: String
	) {
		lock.lock()
		defer { lock.unlock() }
		if let handler {
			handlers[host] = handler
		} else {
			handlers.removeValue(forKey: host)
		}
	}

	/// Returns the handler registered for a specific host.
	/// - Parameter host: The host string.
	/// - Returns: The registered handler, or nil if none.
	nonisolated static func handler(forHost host: String) -> ((URLRequest) throws -> (URLResponse, Data?))? {
		lock.lock()
		defer { lock.unlock() }
		return handlers[host]
	}

	/// Removes all registered handlers.
	nonisolated static func reset() {
		lock.lock()
		defer { lock.unlock() }
		handlers.removeAll()
	}

	nonisolated private static func resolveHandler(
		for request: URLRequest
	) -> ((URLRequest) throws -> (URLResponse, Data?))? {
		lock.lock()
		defer { lock.unlock() }

		// Try host-specific handler first
		if let host = request.url?.host, let handler = handlers[host] {
			return handler
		}
		// Fall back to default
		return handlers["default"]
	}

	// MARK: - URLProtocol

	override nonisolated init(
		request: URLRequest,
		cachedResponse: CachedURLResponse?,
		client: (any URLProtocolClient)?
	) {
		super.init(request: request, cachedResponse: cachedResponse, client: client)
	}

	override nonisolated static func canInit(with request: URLRequest) -> Bool {
		true
	}

	override nonisolated static func canonicalRequest(for request: URLRequest) -> URLRequest {
		request
	}

	override nonisolated func startLoading() {
		guard let handler = Self.resolveHandler(for: request) else {
			client?.urlProtocol(self, didFailWithError: URLError(.badURL))
			return
		}

		do {
			let (response, data) = try handler(request)
			client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			if let data {
				client?.urlProtocol(self, didLoad: data)
			}
			client?.urlProtocolDidFinishLoading(self)
		} catch {
			client?.urlProtocol(self, didFailWithError: error)
		}
	}

	override nonisolated func stopLoading() {}
}

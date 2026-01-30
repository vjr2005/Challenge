import Foundation

final class URLProtocolMock: URLProtocol, @unchecked Sendable {
	nonisolated(unsafe) private static var handlers: [String: (URLRequest) throws -> (URLResponse, Data?)] = [:]
	nonisolated private static let lock = NSLock()

	/// Registers a handler for requests matching the host of the given URL.
	/// - Parameters:
	///   - handler: The handler to invoke for requests to this host. Pass nil to remove.
	///   - url: The URL whose host will be used to match requests.
	nonisolated static func setHandler(
		_ handler: ((URLRequest) throws -> (URLResponse, Data?))?,
		forURL url: URL
	) {
        guard let host = url.host else {
            return
        }
		lock.lock()
		defer { lock.unlock() }
		if let handler {
			handlers[host] = handler
		} else {
			handlers.removeValue(forKey: host)
		}
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
        guard let host = request.url?.host else {
            return nil
        }
		return handlers[host]
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

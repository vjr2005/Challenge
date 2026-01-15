import Foundation

final class URLProtocolMock: URLProtocol, @unchecked Sendable {
	nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (URLResponse, Data?))?

	override nonisolated init(request: URLRequest, cachedResponse: CachedURLResponse?, client: (any URLProtocolClient)?) {
		super.init(request: request, cachedResponse: cachedResponse, client: client)
	}

	override nonisolated static func canInit(with request: URLRequest) -> Bool {
		true
	}

	override nonisolated static func canonicalRequest(for request: URLRequest) -> URLRequest {
		request
	}

	override nonisolated func startLoading() {
		guard let handler = Self.requestHandler else {
			assertionFailure("The handler is not provided!")
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

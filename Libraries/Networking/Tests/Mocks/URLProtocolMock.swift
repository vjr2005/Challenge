import Foundation

final class URLProtocolMock: URLProtocol, @unchecked Sendable {
	nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (URLResponse, Data?))?

	nonisolated override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: (any URLProtocolClient)?) {
		super.init(request: request, cachedResponse: cachedResponse, client: client)
	}

	nonisolated override class func canInit(with request: URLRequest) -> Bool {
		true
	}

	nonisolated override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		request
	}

	nonisolated override func startLoading() {
		guard let handler = URLProtocolMock.requestHandler else {
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

	nonisolated override func stopLoading() {}
}

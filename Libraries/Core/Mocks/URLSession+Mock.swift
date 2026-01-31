import Foundation

public extension URLSession {
	/// Creates a URLSession configured to use URLProtocolMock for all requests.
	/// Use this in tests to intercept network calls.
	static func mockSession() -> URLSession {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [URLProtocolMock.self]
		return URLSession(configuration: configuration)
	}
}

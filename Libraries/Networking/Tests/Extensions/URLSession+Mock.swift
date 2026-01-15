import Foundation

extension URLSession {
	static func mockSession() -> URLSession {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [URLProtocolMock.self]
		return URLSession(configuration: configuration)
	}
}

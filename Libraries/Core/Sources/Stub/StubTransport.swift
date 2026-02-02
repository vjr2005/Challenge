import ChallengeNetworking
import Foundation

/// Transport that responds based on launch arguments configuration.
/// Used in the app when UI test mode is detected.
/// nonisolated because it runs in network context (not MainActor).
nonisolated public struct StubTransport: HTTPTransportContract {
	private let configuration: StubConfiguration

	public init(configuration: StubConfiguration) {
		self.configuration = configuration
	}

	public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
		guard let url = request.url else {
			throw StubTransportError.invalidRequest
		}

		let path = url.path + (url.query.map { "?\($0)" } ?? "")

		for route in configuration.routes where pathMatches(path, pattern: route.pathPattern) {
			let data = Data(base64Encoded: route.bodyBase64) ?? Data()
			guard let response = HTTPURLResponse(
				url: url,
				statusCode: route.statusCode,
				httpVersion: "HTTP/1.1",
				headerFields: ["Content-Type": route.contentType]
			) else {
				throw StubTransportError.invalidResponse
			}
			return (data, response)
		}

		throw StubTransportError.noMatchingRoute(path)
	}

	private func pathMatches(_ path: String, pattern: String) -> Bool {
		let regexPattern = pattern
			.replacingOccurrences(of: ".", with: "\\.")
			.replacingOccurrences(of: "*", with: ".*")
		guard let regex = try? NSRegularExpression(pattern: "^\(regexPattern)$") else {
			return path.contains(pattern)
		}
		let range = NSRange(path.startIndex..., in: path)
		return regex.firstMatch(in: path, range: range) != nil
	}
}

/// Errors that can occur during stub transport.
public enum StubTransportError: Error, Equatable {
	case invalidRequest
	case invalidResponse
	case noMatchingRoute(String)
}

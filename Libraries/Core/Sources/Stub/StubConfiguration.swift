import Foundation

/// Configuration of stubs for UI tests.
/// Serialized to JSON and passed via launch arguments.
/// All response data is embedded in Base64.
/// nonisolated because it needs to be created from both MainActor and non-MainActor contexts.
/// Sendable because it's used by StubTransport which must be thread-safe.
nonisolated public struct StubConfiguration: Codable, Sendable {
	nonisolated public struct Route: Codable, Sendable {
		public let pathPattern: String
		public let statusCode: Int
		public let bodyBase64: String
		public let contentType: String

		public init(
			pathPattern: String,
			statusCode: Int = 200,
			bodyBase64: String = "",
			contentType: String = "application/json"
		) {
			self.pathPattern = pathPattern
			self.statusCode = statusCode
			self.bodyBase64 = bodyBase64
			self.contentType = contentType
		}
	}

	public let routes: [Route]

	public init(routes: [Route]) {
		self.routes = routes
	}

	/// Parses the configuration from launch arguments.
	/// Looks for "--stub-config" followed by Base64-encoded JSON.
	public static func fromLaunchArguments() -> Self? {
		let args = ProcessInfo.processInfo.arguments
		guard let index = args.firstIndex(of: "--stub-config"),
			  index + 1 < args.count,
			  let data = Data(base64Encoded: args[index + 1]),
			  let config = try? JSONDecoder().decode(Self.self, from: data) else {
			return nil
		}
		return config
	}

	/// Serializes to format for launch arguments.
	public func toLaunchArgument() -> [String] {
		guard let data = try? JSONEncoder().encode(self) else {
			return []
		}
		return ["--stub-config", data.base64EncodedString()]
	}
}

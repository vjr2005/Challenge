import Foundation

/// Writes StubConfiguration to a temporary file for communication with the app process.
nonisolated enum StubConfigurationWriter {
	/// Environment variable key for the stub configuration file path.
	static let configPathKey = "STUB_CONFIG_PATH"

	/// Creates a temporary directory for stub configuration files.
	/// - Returns: The URL of the created directory.
	static func createStubDirectory() -> URL {
		let tempDir = FileManager.default.temporaryDirectory
		let stubDir = tempDir.appendingPathComponent("UITestStubs-\(UUID().uuidString)")

		try? FileManager.default.createDirectory(at: stubDir, withIntermediateDirectories: true)
		return stubDir
	}

	/// Writes a stub configuration to a JSON file.
	/// - Parameters:
	///   - configuration: The stub configuration to write.
	///   - directory: The directory to write the file in.
	/// - Returns: The path to the written configuration file.
	static func write(_ configuration: StubConfiguration, to directory: URL) -> String {
		let fileURL = directory.appendingPathComponent("config.json")
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted

		guard let data = try? encoder.encode(configuration) else {
			fatalError("Failed to encode StubConfiguration")
		}

		try? data.write(to: fileURL)
		return fileURL.path
	}

	/// Removes the stub directory and its contents.
	/// - Parameter directory: The directory to remove.
	static func cleanup(directory: URL) {
		try? FileManager.default.removeItem(at: directory)
	}
}

// MARK: - EndpointStub

/// Represents a single stubbed endpoint configuration for UI tests.
nonisolated struct EndpointStub: Codable, Sendable, Equatable {
	/// The path pattern to match (e.g., "/character", "/avatar/*").
	let pathPattern: String
	/// The HTTP method to match. Defaults to "GET".
	let method: String
	/// The HTTP status code to return. Defaults to 200.
	let statusCode: Int
	/// The response body as a string (JSON or plain text).
	let responseBody: String
	/// The Content-Type header value. Defaults to "application/json".
	let contentType: String
	/// Whether the responseBody is Base64 encoded (for binary data like images).
	let isBase64Encoded: Bool
	/// Optional delay in seconds before returning the response.
	let delay: TimeInterval?

	init(
		pathPattern: String,
		method: String = "GET",
		statusCode: Int = 200,
		responseBody: String,
		contentType: String = "application/json",
		isBase64Encoded: Bool = false,
		delay: TimeInterval? = nil
	) {
		self.pathPattern = pathPattern
		self.method = method
		self.statusCode = statusCode
		self.responseBody = responseBody
		self.contentType = contentType
		self.isBase64Encoded = isBase64Encoded
		self.delay = delay
	}
}

// MARK: - StubConfiguration

/// Configuration for stubbing HTTP requests during UI tests.
nonisolated struct StubConfiguration: Codable, Sendable, Equatable {
	/// The base URL that will be intercepted (e.g., "https://rickandmortyapi.com/api").
	let baseURL: String
	/// The list of endpoint configurations.
	let endpoints: [EndpointStub]
	/// Optional default response for unmatched requests.
	let defaultResponse: EndpointStub?

	init(
		baseURL: String,
		endpoints: [EndpointStub],
		defaultResponse: EndpointStub? = nil
	) {
		self.baseURL = baseURL
		self.endpoints = endpoints
		self.defaultResponse = defaultResponse
	}
}

// MARK: - Convenience Extensions

nonisolated extension EndpointStub {
	/// Creates a successful JSON response endpoint.
	static func ok(path: String, body: String) -> Self {
		EndpointStub(pathPattern: path, responseBody: body)
	}

	/// Creates a successful JSON response endpoint with data.
	static func ok(path: String, data: Data) -> Self {
		let body = String(data: data, encoding: .utf8) ?? ""
		return EndpointStub(pathPattern: path, responseBody: body)
	}

	/// Creates an image response endpoint.
	static func image(path: String, data: Data) -> Self {
		EndpointStub(
			pathPattern: path,
			responseBody: data.base64EncodedString(),
			contentType: "image/jpeg",
			isBase64Encoded: true
		)
	}

	/// Creates an error response endpoint.
	static func error(path: String, statusCode: Int, message: String) -> Self {
		EndpointStub(
			pathPattern: path,
			statusCode: statusCode,
			responseBody: "{\"error\": \"\(message)\"}"
		)
	}

	/// Creates a 404 Not Found response endpoint.
	static func notFound(path: String) -> Self {
		error(path: path, statusCode: 404, message: "Not Found")
	}

	/// Creates a 500 Server Error response endpoint.
	static func serverError(path: String) -> Self {
		error(path: path, statusCode: 500, message: "Internal Server Error")
	}
}

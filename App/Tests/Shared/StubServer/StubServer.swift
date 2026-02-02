import Foundation
@preconcurrency import Swifter

/// Response returned by the stub server request handler.
nonisolated struct StubResponse: Sendable {
	let statusCode: Int
	let body: Data
	let contentType: String

	init(statusCode: Int, body: Data, contentType: String = "application/json") {
		self.statusCode = statusCode
		self.body = body
		self.contentType = contentType
	}

	static func ok(_ body: Data) -> Self {
		Self(statusCode: 200, body: body)
	}

	static func image(_ data: Data) -> Self {
		Self(statusCode: 200, body: data, contentType: "image/jpeg")
	}

	static func error(_ statusCode: Int, message: String) -> Self {
		let body = Data("{\"error\": \"\(message)\"}".utf8)
		return Self(statusCode: statusCode, body: body)
	}

	static var notFound: Self {
		error(404, message: "Not Found")
	}

	static var serverError: Self {
		error(500, message: "Internal Server Error")
	}
}

/// A simple HTTP stub server for UI testing.
/// Runs on localhost with a dynamic port and routes requests through a configurable handler.
nonisolated final class StubServer: @unchecked Sendable {
	private var server: HttpServer?
	private var actualPort: UInt16 = 0

	/// Handler called for each request. Receives the request path and returns a response.
	nonisolated(unsafe) var requestHandler: (@Sendable (String) -> StubResponse)?

	/// The base URL where the server is listening.
	var baseURL: String {
		"http://localhost:\(actualPort)"
	}

	/// Starts the stub server on a dynamic port.
	/// - Throws: An error if the server fails to start.
	func start() throws {
		let server = HttpServer()

		server.notFoundHandler = { [weak self] request in
			self?.handleRequest(request) ?? .notFound
		}

		// Use port 0 to let the OS assign an available port
		try server.start(0, forceIPv4: true)
		self.server = server

		let port = try server.port()
		actualPort = UInt16(port)
		print("StubServer: Listening on port \(port)")
	}

	/// Stops the stub server.
	func stop() {
		server?.stop()
		server = nil
		actualPort = 0
	}
}

// MARK: - Private

private extension StubServer {
	nonisolated func handleRequest(_ request: HttpRequest) -> HttpResponse {
		// Build full path with query string to match original behavior
		var fullPath = request.path
		if !request.queryParams.isEmpty {
			let queryString = request.queryParams.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
			fullPath += "?\(queryString)"
		}
		let stubResponse = requestHandler?(fullPath) ?? .error(500, message: "No handler configured")
		return convertToHttpResponse(stubResponse)
	}

	nonisolated func convertToHttpResponse(_ response: StubResponse) -> HttpResponse {
		.raw(response.statusCode, httpStatusText(for: response.statusCode), ["Content-Type": response.contentType]) { writer in
			try writer.write(response.body)
		}
	}

	nonisolated func httpStatusText(for code: Int) -> String {
		switch code {
		case 200: "OK"
		case 400: "Bad Request"
		case 404: "Not Found"
		case 500: "Internal Server Error"
		default: "Unknown"
		}
	}
}

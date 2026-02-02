import Foundation
import Network

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
/// Note: Uses DispatchQueue as required by Network framework's NWListener API.
nonisolated final class StubServer: @unchecked Sendable {
	private var listener: NWListener?
	private let queue = DispatchQueue(label: "StubServer")
	private var connections: [NWConnection] = []
	private var actualPort: UInt16 = 0

	/// Handler called for each request. Receives the request path and returns a response.
	nonisolated(unsafe) var requestHandler: (@Sendable (String) -> StubResponse)?

	/// The base URL where the server is listening.
	var baseURL: String {
		"http://localhost:\(actualPort)"
	}

	/// Starts the stub server on a dynamic port.
	/// Blocks until the server is ready to accept connections.
	/// - Throws: An error if the server fails to start.
	func start() throws {
		let parameters = NWParameters.tcp
		parameters.allowLocalEndpointReuse = true

		// Use port 0 to let the OS assign an available port
		listener = try NWListener(using: parameters, on: .any)

		listener?.newConnectionHandler = { [weak self] connection in
			self?.handleConnection(connection)
		}

		let semaphore = DispatchSemaphore(value: 0)
		let errorBox = ErrorBox()

		listener?.stateUpdateHandler = { [weak self] state in
			switch state {
			case .ready:
				if let port = self?.listener?.port?.rawValue {
					self?.actualPort = port
					print("StubServer: Listening on port \(port)")
				}
				semaphore.signal()
			case let .failed(error):
				print("StubServer: Failed with error \(error)")
				errorBox.error = error
				semaphore.signal()
			case .cancelled:
				print("StubServer: Cancelled")
			default:
				break
			}
		}

		listener?.start(queue: queue)

		// Wait for the server to be ready (with timeout)
		let result = semaphore.wait(timeout: .now() + 5)
		if result == .timedOut {
			listener?.cancel()
			throw StubServerError.startTimeout
		}

		if let error = errorBox.error {
			throw error
		}
	}

	/// Stops the stub server and waits for cleanup to complete.
	func stop() {
		let semaphore = DispatchSemaphore(value: 0)

		listener?.stateUpdateHandler = { state in
			if state == .cancelled {
				semaphore.signal()
			}
		}

		connections.forEach { $0.cancel() }
		connections.removeAll()
		listener?.cancel()

		// Wait for listener to be cancelled (with timeout)
		_ = semaphore.wait(timeout: .now() + 2)

		listener = nil
		actualPort = 0
	}
}

// MARK: - StubServerError

enum StubServerError: Error {
	case startTimeout
}

// MARK: - ErrorBox

/// Thread-safe container for capturing errors in closures.
nonisolated private final class ErrorBox: @unchecked Sendable {
	nonisolated(unsafe) var error: NWError?
}

// MARK: - Private

private extension StubServer {
	nonisolated func handleConnection(_ connection: NWConnection) {
		connections.append(connection)

		connection.start(queue: queue)

		connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, _, _ in
			guard let self, let data, let request = String(data: data, encoding: .utf8) else {
				return
			}

			let response = handleRequest(request)
			sendResponse(response, on: connection)
		}
	}

	nonisolated func handleRequest(_ request: String) -> Data {
		let lines = request.components(separatedBy: "\r\n")
		guard let requestLine = lines.first else {
			return formatResponse(.error(400, message: "Bad Request"))
		}

		let components = requestLine.components(separatedBy: " ")
		guard components.count >= 2 else {
			return formatResponse(.error(400, message: "Bad Request"))
		}

		let path = components[1]
		let stubResponse = requestHandler?(path) ?? .error(500, message: "No handler configured")
		return formatResponse(stubResponse)
	}

	nonisolated func formatResponse(_ response: StubResponse) -> Data {
		let statusText = httpStatusText(for: response.statusCode)
		let header = """
		HTTP/1.1 \(response.statusCode) \(statusText)\r
		Content-Type: \(response.contentType)\r
		Content-Length: \(response.body.count)\r
		Connection: close\r
		\r

		"""
		var data = Data(header.utf8)
		data.append(response.body)
		return data
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

	nonisolated func sendResponse(_ data: Data, on connection: NWConnection) {
		connection.send(content: data, completion: .contentProcessed { _ in
			connection.cancel()
		})
	}
}

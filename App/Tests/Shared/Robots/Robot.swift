import SwiftMockServer
import XCTest

/// Base class for UI tests with mock server support.
nonisolated class UITestCase: XCTestCase {
	private(set) var serverMock: MockServer!
	private(set) var serverBaseURL: String!
	private(set) var app: XCUIApplication!

	override func setUp() async throws {
		try await super.setUp()
		continueAfterFailure = false
		executionTimeAllowance = 60

		serverMock = try await MockServer.create()
		serverBaseURL = await serverMock.baseURL
	}

	override func tearDown() async throws {
		await attachNetworkLogIfFailed()

		await serverMock.stop()
		serverMock = nil
		serverBaseURL = nil
		app = nil
		try await super.tearDown()
	}

	// MARK: - Network Log

	private func attachNetworkLogIfFailed() async {
		guard (testRun?.failureCount ?? 0) > 0 else {
			return
		}

		let requests = await serverMock.requests
		guard !requests.isEmpty else {
			return
		}

		let log = requests
			.enumerated()
			.map { index, recorded in
				formatRequest(recorded, index: index + 1)
			}
			.joined(separator: "\n")

		await XCTContext.runActivity(named: "Network Log") { activity in
			let attachment = XCTAttachment(string: log)
			attachment.name = "Network Log"
			attachment.lifetime = .keepAlways
			activity.add(attachment)
		}
	}

	private func formatRequest(_ recorded: RecordedRequest, index: Int) -> String {
		let request = recorded.request
		let response = recorded.response
		let timestamp = Self.timestampFormatter.string(from: recorded.timestamp)
		var lines = ["[\(index)] \(timestamp) \(request.method.rawValue) \(request.path) → \(response.status.code) \(response.status.reason)"]

		if !request.queryParameters.isEmpty {
			let params = request.queryParameters
				.sorted { $0.key < $1.key }
				.map { "  \($0.key)=\($0.value)" }
				.joined(separator: "\n")
			lines.append("Query:\n\(params)")
		}

		if !request.headers.isEmpty {
			let headers = request.headers
				.sorted { $0.key < $1.key }
				.map { "  \($0.key): \($0.value)" }
				.joined(separator: "\n")
			lines.append("Request Headers:\n\(headers)")
		}

		if let route = recorded.matchedRoute {
			lines.append("Route: \(route)")
		}

		if let body = request.body, !body.isEmpty {
			lines.append("Request Body:\n\(Self.prettyPrintedJSON(body))")
		}

		if !response.headers.isEmpty {
			let headers = response.headers
				.sorted { $0.key < $1.key }
				.map { "  \($0.key): \($0.value)" }
				.joined(separator: "\n")
			lines.append("Response Headers:\n\(headers)")
		}

		if let body = response.body, !body.isEmpty {
			lines.append("Response Body:\n\(Self.prettyPrintedJSON(body))")
		}

		return lines.joined(separator: "\n")
	}

	private static func prettyPrintedJSON(_ data: Data) -> String {
		guard let json = try? JSONSerialization.jsonObject(with: data),
			  let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
			  let string = String(data: pretty, encoding: .utf8)
		else {
			return String(data: data, encoding: .utf8) ?? "<binary \(data.count) bytes>"
		}
		return string
	}

	private static let timestampFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm:ss.SSS"
		return formatter
	}()

	/// Launches the app with the mock server configured.
	/// Configure mock server routes before calling this method.
	/// - Returns: The launched XCUIApplication instance.
	@MainActor
	@discardableResult
	func launch() -> XCUIApplication {
		let app = XCUIApplication()
		app.launchEnvironment = ["API_BASE_URL": serverBaseURL]
		app.launch()

		// Prevents tests from interacting with the UI before the app is ready,
		// which causes "Application failed preflight checks" on slow simulators.
		let isRunning = app.wait(for: .runningForeground, timeout: 10)
		XCTAssertTrue(isRunning, "App failed to reach foreground state")

		self.app = app
		return app
	}

	@MainActor
	func home(actions: (HomeRobot) -> Void) {
		actions(HomeRobot(app: app))
	}

	@MainActor
	func characterList(actions: (CharacterListRobot) -> Void) {
		actions(CharacterListRobot(app: app))
	}

	@MainActor
	func characterDetail(actions: (CharacterDetailRobot) -> Void) {
		actions(CharacterDetailRobot(app: app))
	}

	@MainActor
	func characterFilter(actions: (CharacterFilterRobot) -> Void) {
		actions(CharacterFilterRobot(app: app))
	}

	@MainActor
	func notFound(actions: (NotFoundRobot) -> Void) {
		actions(NotFoundRobot(app: app))
	}

	@MainActor
	func about(actions: (AboutRobot) -> Void) {
		actions(AboutRobot(app: app))
	}

	@MainActor
	func characterEpisodes(actions: (CharacterEpisodesRobot) -> Void) {
		actions(CharacterEpisodesRobot(app: app))
	}
}

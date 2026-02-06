import SwiftMockServer
import XCTest

/// Base protocol for all screen robots.
protocol RobotContract {
	var app: XCUIApplication { get }
}

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
        await serverMock.stop()
		serverMock = nil
		serverBaseURL = nil
		app = nil
		try await super.tearDown()
	}

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
	func advancedSearch(actions: (AdvancedSearchRobot) -> Void) {
		actions(AdvancedSearchRobot(app: app))
	}

	@MainActor
	func notFound(actions: (NotFoundRobot) -> Void) {
		actions(NotFoundRobot(app: app))
	}

	@MainActor
	func about(actions: (AboutRobot) -> Void) {
		actions(AboutRobot(app: app))
	}
}

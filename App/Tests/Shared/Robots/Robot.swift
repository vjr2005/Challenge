/*
import XCTest

/// Base protocol for all screen robots.
protocol RobotContract {
	var app: XCUIApplication { get }
}

/// Base class for UI tests with stub server support.
nonisolated class UITestCase: XCTestCase {
	private(set) var stubServer: StubServer!
	private(set) var app: XCUIApplication!

	override func setUpWithError() throws {
		try super.setUpWithError()
		continueAfterFailure = false
		executionTimeAllowance = 60

		stubServer = StubServer()
		try stubServer.start()
	}

	override func tearDownWithError() throws {
		stubServer.stop()
		stubServer = nil
		app = nil
		try super.tearDownWithError()
	}

	/// Launches the app with the stub server configured.
	/// Configure `stubServer.requestHandler` before calling this method.
	/// - Returns: The launched XCUIApplication instance.
	@MainActor
	@discardableResult
	func launch() -> XCUIApplication {
		let app = XCUIApplication()
		app.launchEnvironment = ["API_BASE_URL": stubServer.baseURL]
		app.launch()

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
	func notFound(actions: (NotFoundRobot) -> Void) {
		actions(NotFoundRobot(app: app))
	}
}
*/

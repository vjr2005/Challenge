import ChallengeCore
import XCTest

/// Base protocol for all screen robots.
protocol RobotContract {
	var app: XCUIApplication { get }
}

/// Base class for UI tests with stub configuration support.
/// nonisolated because XCTestCase requires execution outside MainActor.
nonisolated class UITestCase: XCTestCase {
	nonisolated(unsafe) private var _stubConfig: StubConfigurationBuilder?
	nonisolated(unsafe) private(set) var app: XCUIApplication!

	/// Returns the stub configuration builder, creating it if needed.
	/// Must be accessed from @MainActor context.
	@MainActor
	var stubConfig: StubConfigurationBuilder {
		if let config = _stubConfig {
			return config
		}
		let config = StubConfigurationBuilder.create()
		_stubConfig = config
		return config
	}

	override func setUpWithError() throws {
		try super.setUpWithError()
		continueAfterFailure = false
		executionTimeAllowance = 60
	}

	override func tearDownWithError() throws {
		_stubConfig = nil
		app = nil
		try super.tearDownWithError()
	}

	/// Launches the app with the stub configuration.
	/// Configure `stubConfig` before calling this method.
	/// - Returns: The launched XCUIApplication instance.
	@MainActor
	@discardableResult
	func launch() -> XCUIApplication {
		let app = XCUIApplication()
		app.launchArguments = stubConfig.build().toLaunchArgument()
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

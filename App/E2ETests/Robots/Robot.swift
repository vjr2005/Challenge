import XCTest

/// Base protocol for all screen robots.
protocol RobotContract {
	var app: XCUIApplication { get }
}

/// Provides DSL for robot-based testing.
extension XCTestCase {
	func launch() -> XCUIApplication {
		let app = XCUIApplication()
		app.launch()
		return app
	}

	func home(
		app: XCUIApplication,
		actions: (HomeRobot) -> Void
	) {
		actions(HomeRobot(app: app))
	}

	func characterList(
		app: XCUIApplication,
		actions: (CharacterListRobot) -> Void
	) {
		actions(CharacterListRobot(app: app))
	}

	func characterDetail(
		app: XCUIApplication,
		actions: (CharacterDetailRobot) -> Void
	) {
		actions(CharacterDetailRobot(app: app))
	}
}

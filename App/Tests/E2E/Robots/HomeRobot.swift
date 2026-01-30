import XCTest

struct HomeRobot: RobotContract {
	let app: XCUIApplication
}

// MARK: - Actions

extension HomeRobot {
	@discardableResult
	func tapCharacterButton(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let button = app.buttons[AccessibilityIdentifier.characterButton]
		XCTAssertTrue(button.waitForExistence(timeout: 5), file: file, line: line)
		button.tap()
		return self
	}
}

// MARK: - Verifications

extension HomeRobot {
	@discardableResult
	func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let button = app.buttons[AccessibilityIdentifier.characterButton]
		XCTAssertTrue(button.waitForExistence(timeout: 5), file: file, line: line)
		return self
	}
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
	static let characterButton = "home.characterButton"
}

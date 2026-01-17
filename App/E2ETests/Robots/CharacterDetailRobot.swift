import XCTest

struct CharacterDetailRobot: RobotContract {
	let app: XCUIApplication
}

// MARK: - Actions

extension CharacterDetailRobot {
	@discardableResult
	func tapBack(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let backButton = app.buttons[AccessibilityIdentifier.backButton]
		XCTAssertTrue(backButton.waitForExistence(timeout: 5), file: file, line: line)
		backButton.tap()
		return self
	}
}

// MARK: - Verifications

extension CharacterDetailRobot {
	@discardableResult
	func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let view = app.descendants(matching: .any)[AccessibilityIdentifier.view]
		XCTAssertTrue(view.waitForExistence(timeout: 5), file: file, line: line)
		return self
	}
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
	static let view = "characterDetail.view"
	static let backButton = "characterDetail.backButton"
}

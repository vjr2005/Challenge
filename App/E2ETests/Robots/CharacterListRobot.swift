import XCTest

struct CharacterListRobot: RobotContract {
	let app: XCUIApplication
}

// MARK: - Actions

extension CharacterListRobot {
	@discardableResult
	func tapCharacter(id: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
		let identifier = AccessibilityIdentifier.row(id: id)
		let row = app.descendants(matching: .any)[identifier].firstMatch
		XCTAssertTrue(row.waitForExistence(timeout: 10), file: file, line: line)
		row.tap()
		return self
	}

	@discardableResult
	func tapBack(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let backButton = app.navigationBars.buttons.element(boundBy: 0)
		XCTAssertTrue(backButton.waitForExistence(timeout: 5), file: file, line: line)
		backButton.tap()
		return self
	}
}

// MARK: - Verifications

extension CharacterListRobot {
	@discardableResult
	func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let scrollView = app.scrollViews[AccessibilityIdentifier.scrollView]
		XCTAssertTrue(scrollView.waitForExistence(timeout: 5), file: file, line: line)
		return self
	}
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
	static let scrollView = "characterList.scrollView"

	static func row(id: Int) -> String {
		"characterList.row.\(id)"
	}
}

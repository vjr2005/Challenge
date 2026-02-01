import XCTest

struct NotFoundRobot: RobotContract {
	let app: XCUIApplication
}

// MARK: - Actions

extension NotFoundRobot {
	@discardableResult
	func tapGoBack(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let button = app.buttons[AccessibilityIdentifier.goBackButton]
		XCTAssertTrue(button.waitForExistence(timeout: 5), file: file, line: line)
		button.tap()
		return self
	}
}

// MARK: - Verifications

extension NotFoundRobot {
	@discardableResult
	func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let title = app.descendants(matching: .any)[AccessibilityIdentifier.title]
		XCTAssertTrue(title.waitForExistence(timeout: 5), file: file, line: line)
		return self
	}
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
	static let title = "system.notFound.container.title"
	static let goBackButton = "system.notFound.container.button"
}

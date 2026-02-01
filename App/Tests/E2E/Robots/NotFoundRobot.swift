import XCTest

struct NotFoundRobot: RobotContract {
	let app: XCUIApplication
}

// MARK: - Actions

extension NotFoundRobot {
	@discardableResult
	func tapGoBack(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let container = app.descendants(matching: .any)[AccessibilityIdentifier.container]
		XCTAssertTrue(container.waitForExistence(timeout: 5), file: file, line: line)
		let button = container.buttons.firstMatch
		XCTAssertTrue(button.waitForExistence(timeout: 5), file: file, line: line)
		button.tap()
		return self
	}
}

// MARK: - Verifications

extension NotFoundRobot {
	@discardableResult
	func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let container = app.descendants(matching: .any)[AccessibilityIdentifier.container]
		XCTAssertTrue(container.waitForExistence(timeout: 5), file: file, line: line)
		return self
	}
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
	static let container = "system.notFound.container"
}

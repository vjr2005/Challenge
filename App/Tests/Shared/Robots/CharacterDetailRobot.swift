import XCTest

struct CharacterDetailRobot {
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

	@discardableResult
	func pullToRefresh(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let scrollView = app.scrollViews[AccessibilityIdentifier.scrollView]
		XCTAssertTrue(scrollView.waitForExistence(timeout: 5), file: file, line: line)
		let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
		let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
		start.press(forDuration: 0.1, thenDragTo: end)
		return self
	}

	@discardableResult
	func tapRetry(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let retryButton = app.buttons[AccessibilityIdentifier.retryButton]
		XCTAssertTrue(retryButton.waitForExistence(timeout: 5), file: file, line: line)
		retryButton.tap()
		return self
	}
}

// MARK: - Verifications

extension CharacterDetailRobot {
	@discardableResult
	func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let view = app.descendants(matching: .any)[AccessibilityIdentifier.name]
		XCTAssertTrue(view.waitForExistence(timeout: 5), file: file, line: line)
		return self
	}

	@discardableResult
	func verifyErrorIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let errorTitle = app.descendants(matching: .any)[AccessibilityIdentifier.errorTitle]
		XCTAssertTrue(errorTitle.waitForExistence(timeout: 5), file: file, line: line)
		return self
	}
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
	static let scrollView = "characterDetail.scrollView"
	static let name = "characterDetail.name"
	static let backButton = "characterDetail.backButton"
	static let errorTitle = "characterDetail.errorView.title"
	static let retryButton = "characterDetail.errorView.button"
}

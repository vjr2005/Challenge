import XCTest

struct CharacterEpisodesRobot {
	let app: XCUIApplication
}

// MARK: - Actions

extension CharacterEpisodesRobot {
	@discardableResult
	func pullToRefresh(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let scrollView = app.scrollViews[AccessibilityIdentifier.scrollView]
		XCTAssertTrue(scrollView.waitForExistence(timeout: 10), file: file, line: line)
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

	@discardableResult
	func tapBack(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let backButton = app.navigationBars.buttons.element(boundBy: 0)
		XCTAssertTrue(backButton.waitForExistence(timeout: 5), file: file, line: line)
		backButton.tap()
		return self
	}

	@discardableResult
	func tapCharacter(identifier: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
		let accessibilityId = AccessibilityIdentifier.characterAvatar(id: identifier)
		let avatar = app.descendants(matching: .any)[accessibilityId].firstMatch
		XCTAssertTrue(avatar.waitForExistence(timeout: 10), file: file, line: line)
		avatar.tap()
		return self
	}
}

// MARK: - Verifications

extension CharacterEpisodesRobot {
	@discardableResult
	func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let view = app.scrollViews[AccessibilityIdentifier.scrollView]
		XCTAssertTrue(view.waitForExistence(timeout: 10), file: file, line: line)
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
	static let scrollView = "characterEpisodes.scrollView"
	static let errorTitle = "characterEpisodes.errorView.title"
	static let retryButton = "characterEpisodes.errorView.button"

	static func characterAvatar(id: Int) -> String {
		"characterEpisodes.character.\(id)"
	}
}

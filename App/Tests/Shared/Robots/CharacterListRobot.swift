import XCTest

struct CharacterListRobot: RobotContract {
	let app: XCUIApplication
}

// MARK: - Actions

extension CharacterListRobot {
	@discardableResult
	func tapCharacter(identifier: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
		let accessibilityId = AccessibilityIdentifier.row(identifier: identifier)
		let row = app.descendants(matching: .any)[accessibilityId].firstMatch
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

	@discardableResult
	func typeSearch(text: String, file: StaticString = #filePath, line: UInt = #line) -> Self {
		let searchField = app.searchFields.firstMatch
		XCTAssertTrue(searchField.waitForExistence(timeout: 5), file: file, line: line)
		searchField.tap()
		searchField.typeText(text)
		return self
	}

	@discardableResult
	func clearSearch(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let searchField = app.searchFields.firstMatch
		XCTAssertTrue(searchField.waitForExistence(timeout: 5), file: file, line: line)
		searchField.tap()
		searchField.buttons["Clear text"].tap()
		return self
	}

	@discardableResult
	func tapLoadMore(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let button = app.buttons[AccessibilityIdentifier.loadMoreButton]
		XCTAssertTrue(button.waitForExistence(timeout: 10), file: file, line: line)
		button.tap()
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

extension CharacterListRobot {
	@discardableResult
	func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let scrollView = app.scrollViews[AccessibilityIdentifier.scrollView]
		XCTAssertTrue(scrollView.waitForExistence(timeout: 5), file: file, line: line)
		return self
	}

	@discardableResult
	func verifyCharacterExists(identifier: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
		let scrollView = app.scrollViews[AccessibilityIdentifier.scrollView]
		let accessibilityId = AccessibilityIdentifier.row(identifier: identifier)
		let row = app.descendants(matching: .any)[accessibilityId].firstMatch
		XCTAssertTrue(row.waitForExistence(timeout: 10), file: file, line: line)
		// Scroll to make the row visible if needed
		var attempts = 0
		while !row.isHittable && attempts < 10 {
			scrollView.swipeUp()
			attempts += 1
		}
		XCTAssertTrue(row.isHittable, "Character row \(identifier) should be visible", file: file, line: line)
		return self
	}

	@discardableResult
	func verifyCharacterDoesNotExist(identifier: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
		let accessibilityId = AccessibilityIdentifier.row(identifier: identifier)
		let row = app.descendants(matching: .any)[accessibilityId].firstMatch
		XCTAssertFalse(row.waitForExistence(timeout: 2), "Character row \(identifier) should not exist", file: file, line: line)
		return self
	}

	@discardableResult
	func verifyEmptyStateIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let emptyState = app.descendants(matching: .any)[AccessibilityIdentifier.emptyStateTitle]
		XCTAssertTrue(emptyState.waitForExistence(timeout: 5), file: file, line: line)
		return self
	}

	@discardableResult
	func verifyEmptySearchStateIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let emptySearchState = app.descendants(matching: .any)[AccessibilityIdentifier.emptySearchStateTitle]
		XCTAssertTrue(emptySearchState.waitForExistence(timeout: 5), file: file, line: line)
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
	static let scrollView = "characterList.scrollView"
	static let loadMoreButton = "characterList.loadMore.button"
	static let emptyStateTitle = "characterList.emptyState.title"
	static let emptySearchStateTitle = "characterList.emptySearchState.title"
	static let errorTitle = "characterList.errorView.title"
	static let retryButton = "characterList.errorView.button"

	static func row(identifier: Int) -> String {
		"characterList.row.\(identifier)"
	}
}

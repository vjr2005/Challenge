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
		let scrollView = app.scrollViews[AccessibilityIdentifier.scrollView]
		let button = app.buttons[AccessibilityIdentifier.loadMoreButton]
		// Scroll down to find and tap the button
		for _ in 0..<5 {
			if button.exists && button.isHittable {
				break
			}
			scrollView.swipeUp()
		}
		XCTAssertTrue(button.waitForExistence(timeout: 10), file: file, line: line)
		button.tap()
		return self
	}

	@discardableResult
	func pullToRefresh(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let scrollView = app.scrollViews[AccessibilityIdentifier.scrollView]
		XCTAssertTrue(scrollView.waitForExistence(timeout: 5), file: file, line: line)
		scrollView.swipeDown()
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
	func verifyCharacterExists(id: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
		let scrollView = app.scrollViews[AccessibilityIdentifier.scrollView]
		let identifier = AccessibilityIdentifier.row(id: id)
		let row = app.descendants(matching: .any)[identifier].firstMatch
		XCTAssertTrue(row.waitForExistence(timeout: 10), file: file, line: line)
		// Scroll to make the row visible if needed
		var attempts = 0
		while !row.isHittable && attempts < 10 {
			scrollView.swipeUp()
			attempts += 1
		}
		XCTAssertTrue(row.isHittable, "Character row \(id) should be visible", file: file, line: line)
		return self
	}

	@discardableResult
	func verifyEmptyStateIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let emptyState = app.descendants(matching: .any)[AccessibilityIdentifier.emptyState]
		XCTAssertTrue(emptyState.waitForExistence(timeout: 5), file: file, line: line)
		return self
	}

	@discardableResult
	func verifyLoadMoreButtonExists(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let scrollView = app.scrollViews[AccessibilityIdentifier.scrollView]
		let button = app.buttons[AccessibilityIdentifier.loadMoreButton]
		// Scroll down to find the button (it's at the bottom of the list)
		for _ in 0..<5 {
			if button.exists && button.isHittable {
				break
			}
			scrollView.swipeUp()
		}
		XCTAssertTrue(button.waitForExistence(timeout: 10), file: file, line: line)
		return self
	}
}

// MARK: - DS Accessibility Identifiers Verification

extension CharacterListRobot {
	@discardableResult
	func verifyRowTitleIdentifierExists(id: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
		let identifier = "characterList.row.\(id).title"
		let element = app.descendants(matching: .any)[identifier].firstMatch
		XCTAssertTrue(
			element.waitForExistence(timeout: 10),
			"Expected accessibility identifier '\(identifier)' to exist",
			file: file,
			line: line
		)
		return self
	}

	@discardableResult
	func verifyRowImageIdentifierExists(id: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
		let identifier = "characterList.row.\(id).image"
		let element = app.descendants(matching: .any)[identifier].firstMatch
		XCTAssertTrue(
			element.waitForExistence(timeout: 10),
			"Expected accessibility identifier '\(identifier)' to exist",
			file: file,
			line: line
		)
		return self
	}

	@discardableResult
	func verifyRowStatusIdentifierExists(id: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
		let identifier = "characterList.row.\(id).status"
		let element = app.descendants(matching: .any)[identifier].firstMatch
		XCTAssertTrue(
			element.waitForExistence(timeout: 10),
			"Expected accessibility identifier '\(identifier)' to exist",
			file: file,
			line: line
		)
		return self
	}
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
	static let scrollView = "characterList.scrollView"
	static let loadMoreButton = "characterList.loadMoreButton.button"
	static let emptyState = "characterList.emptyState"

	static func row(id: Int) -> String {
		"characterList.row.\(id)"
	}
}

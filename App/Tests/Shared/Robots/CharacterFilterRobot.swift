import XCTest

struct CharacterFilterRobot {
	let app: XCUIApplication
}

// MARK: - Actions

extension CharacterFilterRobot {
	@discardableResult
	func tapStatusChip(_ label: String, file: StaticString = #filePath, line: UInt = #line) -> Self {
		let chip = app.buttons[AccessibilityIdentifier.statusChip(label: label)]
		XCTAssertTrue(chip.waitForExistence(timeout: 5), file: file, line: line)
		chip.tap()
		return self
	}

	@discardableResult
	func tapGenderChip(_ label: String, file: StaticString = #filePath, line: UInt = #line) -> Self {
		let chip = app.buttons[AccessibilityIdentifier.genderChip(label: label)]
		XCTAssertTrue(chip.waitForExistence(timeout: 5), file: file, line: line)
		chip.tap()
		return self
	}

	@discardableResult
	func typeSpecies(text: String, file: StaticString = #filePath, line: UInt = #line) -> Self {
		let textField = app.textFields[AccessibilityIdentifier.speciesTextField]
		XCTAssertTrue(textField.waitForExistence(timeout: 5), file: file, line: line)
		textField.tap()
		textField.typeText(text)
		return self
	}

	@discardableResult
	func typeType(text: String, file: StaticString = #filePath, line: UInt = #line) -> Self {
		let textField = app.textFields[AccessibilityIdentifier.typeTextField]
		XCTAssertTrue(textField.waitForExistence(timeout: 5), file: file, line: line)
		textField.tap()
		textField.typeText(text)
		return self
	}

	@discardableResult
	func tapApply(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let button = app.buttons[AccessibilityIdentifier.applyButton]
		XCTAssertTrue(button.waitForExistence(timeout: 5), file: file, line: line)
		button.tap()
		return self
	}

	@discardableResult
	func tapReset(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let button = app.buttons[AccessibilityIdentifier.resetButton]
		XCTAssertTrue(button.waitForExistence(timeout: 5), file: file, line: line)
		button.tap()
		return self
	}

	@discardableResult
	func tapClose(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let button = app.buttons[AccessibilityIdentifier.closeButton]
		XCTAssertTrue(button.waitForExistence(timeout: 5), file: file, line: line)
		button.tap()
		return self
	}
}

// MARK: - Verifications

extension CharacterFilterRobot {
	@discardableResult
	func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let button = app.buttons[AccessibilityIdentifier.applyButton]
		XCTAssertTrue(button.waitForExistence(timeout: 5), file: file, line: line)
		return self
	}
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
	static let closeButton = "characterFilter.close.button"
	static let resetButton = "characterFilter.reset.button"
	static let applyButton = "characterFilter.apply.button"
	static let speciesTextField = "characterFilter.species.textField"
	static let typeTextField = "characterFilter.type.textField"

	static func statusChip(label: String) -> String {
		"characterFilter.status.\(label)"
	}

	static func genderChip(label: String) -> String {
		"characterFilter.gender.\(label)"
	}
}

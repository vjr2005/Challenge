import XCTest

struct AboutRobot {
	let app: XCUIApplication
}

// MARK: - Actions

extension AboutRobot {
	@discardableResult
	func tapClose(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let button = app.buttons[AccessibilityIdentifier.closeButton]
		XCTAssertTrue(button.waitForExistence(timeout: 5), file: file, line: line)
		button.tap()
		return self
	}
}

// MARK: - Verifications

extension AboutRobot {
	@discardableResult
	func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let element = app.staticTexts[AccessibilityIdentifier.appName]
		XCTAssertTrue(element.waitForExistence(timeout: 5), file: file, line: line)
		return self
	}

	@discardableResult
	func verifyFeaturesExist(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let element = app.staticTexts[AccessibilityIdentifier.featureBrowseValue]
		XCTAssertTrue(element.waitForExistence(timeout: 5), file: file, line: line)
		return self
	}

	@discardableResult
	func verifyDeveloperExists(file: StaticString = #filePath, line: UInt = #line) -> Self {
		let element = app.staticTexts[AccessibilityIdentifier.developerValue]
		XCTAssertTrue(element.waitForExistence(timeout: 5), file: file, line: line)
		return self
	}
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
	static let closeButton = "about.close.button"
	static let appName = "about.appName"
	static let featureBrowseValue = "about.feature.browse.value"
	static let developerValue = "about.developer.value"
}

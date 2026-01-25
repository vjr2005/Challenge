import XCTest

/// End-to-end tests for deep link navigation.
nonisolated final class DeepLinkE2ETests: XCTestCase {
	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testDeepLinkToCharacterList() throws {
		// Given
		let app = launch()
		let url = try XCTUnwrap(URL(string: "challenge://character/list"))

		// When
		app.open(url)

		// Then
		characterList(app: app) { robot in
			robot.verifyIsVisible()
		}
	}

	@MainActor
	func testDeepLinkToCharacterDetail() throws {
		// Given
		let app = launch()
		let url = try XCTUnwrap(URL(string: "challenge://character/detail?id=1"))

		// When
		app.open(url)

		// Then
		characterDetail(app: app) { robot in
			robot.verifyIsVisible()
		}
	}
}

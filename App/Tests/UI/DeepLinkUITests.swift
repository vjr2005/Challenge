import XCTest

/// UI tests for deep link navigation.
final class DeepLinkUITests: UITestCase {
	@MainActor
	func testDeepLinkToCharacterList() throws {
		// Given
		stubConfig
			.stub(path: "/api/character/avatar/*", data: Data.stubAvatarImage, contentType: "image/jpeg")
			.stub(path: "/api/character*", fixture: "characters_response")

		launch()
		let url = try XCTUnwrap(URL(string: "challenge://character/list"))

		// When
		app.open(url)

		// Then
		characterList { robot in
			robot.verifyIsVisible()
		}
	}

	@MainActor
	func testDeepLinkToCharacterDetail() throws {
		// Given
		stubConfig
			.stub(path: "/api/character/avatar/*", data: Data.stubAvatarImage, contentType: "image/jpeg")
			.stub(path: "/api/character/*", fixture: "character")

		launch()
		let url = try XCTUnwrap(URL(string: "challenge://character/detail?id=1"))

		// When
		app.open(url)

		// Then
		characterDetail { robot in
			robot.verifyIsVisible()
		}
	}

	@MainActor
	func testInvalidDeepLinkShowsNotFound() throws {
		// Given - no stubs needed for invalid route

		launch()
		let url = try XCTUnwrap(URL(string: "challenge://invalid/route"))

		// When
		app.open(url)

		// Then
		notFound { robot in
			robot.verifyIsVisible()
			robot.tapGoBack()
		}

		home { robot in
			robot.verifyIsVisible()
		}
	}
}

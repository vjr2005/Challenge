import XCTest

/// UI tests for deep link navigation.
final class DeepLinkUITests: UITestCase {
	@MainActor
	func testDeepLinkToCharacterList() throws {
		// Given
		let charactersData = Data.fixture("characters_response")
		let imageData = Data.stubAvatarImage

		configureStubs([
			.image(path: "/avatar/1.jpeg", data: imageData),
			.ok(path: "/character", data: charactersData)
		])

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
		let characterData = Data.fixture("character")
		let imageData = Data.stubAvatarImage

		configureStubs([
			.image(path: "/avatar/1.jpeg", data: imageData),
			.ok(path: "/character/1", data: characterData)
		])

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
		// Given
		configureStubs([])

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

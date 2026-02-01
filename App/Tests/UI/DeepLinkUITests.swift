/*
import XCTest

/// UI tests for deep link navigation.
final class DeepLinkUITests: UITestCase {
	@MainActor
	func testDeepLinkToCharacterList() throws {
		// Given
		let charactersData = Data.fixture("characters_response")
		let imageData = Data.stubAvatarImage

		stubServer.requestHandler = { path in
			if path.contains("/avatar/") {
				return .image(imageData)
			}
			if path.contains("/character") {
				return .ok(charactersData)
			}
			return .notFound
		}

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

		stubServer.requestHandler = { path in
			if path.contains("/avatar/") {
				return .image(imageData)
			}
			if path.contains("/character/") {
				return .ok(characterData)
			}
			return .notFound
		}

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
		stubServer.requestHandler = { _ in
			.notFound
		}

		launch()
		let url = try XCTUnwrap(URL(string: "challenge://invalid/route"))

		// When
		app.open(url)

		// Then
		notFound { robot in
			robot.verifyIsVisible()
		}
	}
}
*/

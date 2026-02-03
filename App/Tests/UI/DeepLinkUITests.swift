import SwiftMockServer
import XCTest
/*
/// UI tests for deep link navigation.
final class DeepLinkUITests: UITestCase {
	@MainActor
	func testDeepLinkToCharacterList() async throws {
		// Given
		let baseURL = try XCTUnwrap(serverBaseURL)
		let charactersData = Data.fixture("characters_response", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
                return .image(imageData)
			}
			if request.path.contains("/character") {
				return .json(charactersData)
			}
			return .status(.notFound)
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
	func testDeepLinkToCharacterDetail() async throws {
		// Given
		let baseURL = try XCTUnwrap(serverBaseURL)
		let characterData = Data.fixture("character", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
                return .image(imageData)
			}
			if request.path.contains("/character/") {
				return .json(characterData)
			}
			return .status(.notFound)
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
	func testInvalidDeepLinkShowsNotFound() async throws {
		// Given
		await serverMock.registerCatchAll { _ in
			.status(.notFound)
		}

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
*/

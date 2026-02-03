import SwiftMockServer
import XCTest

/// UI tests for the character browsing flow.
final class CharacterFlowUITests: UITestCase {
	@MainActor
	func testListPaginationLoadsMoreAndPullToRefreshResetsContent() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let page1Data = Data.fixture("characters_response", baseURL: baseURL)
		let page2Data = Data.fixture("characters_response_page_2", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
                return .image(imageData)
			}
			if request.path.contains("/character") {
				if request.queryParameters["page"] == "2" {
                    return .json(page2Data)
				}
                return .json(page1Data)
			}
			return .status(.notFound)
		}

		// When
		launch()

		// Then
		home { robot in
			robot.tapCharacterButton()
		}

		characterList { robot in
			// Verify only one element exists
			robot.verifyIsVisible()
			robot.verifyCharacterExists(identifier: 1)
			robot.verifyCharacterDoesNotExist(identifier: 21)

			// Tap load more and verify two elements exist
			robot.tapLoadMore()
			robot.verifyCharacterExists(identifier: 1)
			robot.verifyCharacterExists(identifier: 21)

			// Pull to refresh and verify only one element exists again
			robot.pullToRefresh()
			robot.verifyCharacterExists(identifier: 1)
			robot.verifyCharacterDoesNotExist(identifier: 21)
		}
	}

	@MainActor
	func testListShowsErrorAndRetryLoadsContent() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let charactersData = Data.fixture("characters_response", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { _ in
			.status(.internalServerError)
		}

		// When
		launch()

		// Then
		home { robot in
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyErrorIsVisible()
		}

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/character") {
				return .json(charactersData)
			}
			return .status(.notFound)
		}

		characterList { robot in
			robot.tapRetry()
			robot.verifyIsVisible()
			robot.verifyCharacterExists(identifier: 1)
		}
	}

	@MainActor
	func testSearchShowsEmptyStateAndClearSearchRestoresContent() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let charactersData = Data.fixture("characters_response", baseURL: baseURL)
		let emptyData = Data.fixture("characters_response_empty")
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/character") {
				if request.queryParameters["name"] != nil {
					return .json(emptyData)
				}
				return .json(charactersData)
			}
			return .status(.notFound)
		}

		// When
		launch()

		// Then
		home { robot in
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.verifyCharacterExists(identifier: 1)
			robot.typeSearch(text: "NonExistent")
			robot.verifyEmptyStateIsVisible()
			robot.clearSearch()
			robot.verifyCharacterExists(identifier: 1)
		}
	}

	@MainActor
	func testNavigationFromListToDetailAndBackWithPullToRefresh() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let charactersData = Data.fixture("characters_response", baseURL: baseURL)
		let characterData = Data.fixture("character", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/character/") {
				return .json(characterData)
			}
			if request.path.contains("/character") {
				return .json(charactersData)
			}
			return .status(.notFound)
		}

		// When
		launch()

		// Then
		home { robot in
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.pullToRefresh()
			robot.verifyIsVisible()
			robot.tapCharacter(identifier: 1)
		}

		characterDetail { robot in
			robot.verifyIsVisible()
			robot.pullToRefresh()
			robot.verifyIsVisible()
			robot.tapBack()
		}

		characterList { robot in
			robot.tapBack()
		}

		home { robot in
			robot.verifyIsVisible()
		}
	}

	@MainActor
	func testDetailShowsErrorAndRetryKeepsShowingError() async throws {
		let baseURL = try XCTUnwrap(serverBaseURL)
		let charactersData = Data.fixture("characters_response", baseURL: baseURL)
		let imageData = Data.stubAvatarImage

		await serverMock.registerCatchAll { request in
			if request.path.contains("/avatar/") {
				return .image(imageData)
			}
			if request.path.contains("/character/") {
				return .status(.internalServerError)
			}
			if request.path.contains("/character") {
				return .json(charactersData)
			}
			return .status(.notFound)
		}

		// When
		launch()

		// Then
		home { robot in
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.tapCharacter(identifier: 1)
		}

		characterDetail { robot in
			robot.verifyErrorIsVisible()
			robot.tapRetry()
			robot.verifyErrorIsVisible()
		}
	}
}

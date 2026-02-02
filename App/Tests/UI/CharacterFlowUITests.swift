import XCTest

/// UI tests for the character browsing flow.
final class CharacterFlowUITests: UITestCase {
	@MainActor
	func testListPaginationLoadsMoreAndPullToRefreshResetsContent() throws {
		// Given
		stubConfig
			.stub(path: "/api/character/avatar/*", data: Data.stubAvatarImage, contentType: "image/jpeg")
			.stub(path: "/api/character*page=2*", fixture: "characters_response_page_2")
			.stub(path: "/api/character*", fixture: "characters_response")

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
	func testListShowsErrorAndRetryKeepsShowingError() throws {
		// Given
		stubConfig.stubError(path: "/api/character*")

		// When
		launch()

		// Then
		home { robot in
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyErrorIsVisible()
			robot.tapRetry()
			robot.verifyErrorIsVisible()
		}
	}

	@MainActor
	func testSearchShowsEmptyStateAndClearSearchRestoresContent() throws {
		// Given
		stubConfig
			.stub(path: "/api/character/avatar/*", data: Data.stubAvatarImage, contentType: "image/jpeg")
			.stub(path: "/api/character*name=*", fixture: "characters_response_empty")
			.stub(path: "/api/character*", fixture: "characters_response")

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
	func testNavigationFromListToDetailAndBackWithPullToRefresh() throws {
		// Given
		stubConfig
			.stub(path: "/api/character/avatar/*", data: Data.stubAvatarImage, contentType: "image/jpeg")
			.stub(path: "/api/character/*", fixture: "character")
			.stub(path: "/api/character*", fixture: "characters_response")

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
	func testDetailShowsErrorAndRetryKeepsShowingError() throws {
		// Given
		stubConfig
			.stub(path: "/api/character/avatar/*", data: Data.stubAvatarImage, contentType: "image/jpeg")
			.stubError(path: "/api/character/*")
			.stub(path: "/api/character*", fixture: "characters_response")

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

import XCTest

/// UI tests for the character browsing flow.
final class CharacterFlowUITests: UITestCase {
	@MainActor
	func testListPaginationLoadsMoreAndPullToRefreshResetsContent() throws {
		// Given
		let page1Data = Data.fixture("characters_response")
		let page2Data = Data.fixture("characters_response_page_2")
		let imageData = Data.stubAvatarImage

		configureStubs([
			.image(path: "/avatar/1.jpeg", data: imageData),
			.image(path: "/avatar/21.jpeg", data: imageData),
			.ok(path: "/character?page=2", data: page2Data),
			.ok(path: "/character", data: page1Data)
		])

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
		configureStubs([
			.serverError(path: "/character")
		])

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
		let charactersData = Data.fixture("characters_response")
		let emptyData = Data.fixture("characters_response_empty")
		let imageData = Data.stubAvatarImage

		configureStubs([
			.image(path: "/avatar/1.jpeg", data: imageData),
			.ok(path: "/character?name=NonExistent", data: emptyData),
			.ok(path: "/character", data: charactersData)
		])

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
		let charactersData = Data.fixture("characters_response")
		let characterData = Data.fixture("character")
		let imageData = Data.stubAvatarImage

		configureStubs([
			.image(path: "/avatar/1.jpeg", data: imageData),
			.ok(path: "/character/1", data: characterData),
			.ok(path: "/character", data: charactersData)
		])

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
		let charactersData = Data.fixture("characters_response")
		let imageData = Data.stubAvatarImage

		configureStubs([
			.image(path: "/avatar/1.jpeg", data: imageData),
			.serverError(path: "/character/1"),
			.ok(path: "/character", data: charactersData)
		])

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

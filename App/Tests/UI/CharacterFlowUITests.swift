import XCTest

/// UI tests for the character browsing flow.
final class CharacterFlowUITests: UITestCase {
	@MainActor
	func testListPaginationLoadsMoreAndPullToRefreshResetsContent() async throws {
		// Given
		try await givenCharacterListWithPaginationSucceeds()

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
		// Given
		await givenAllRequestsFail()

		// When
		launch()

		// Then
		home { robot in
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyErrorIsVisible()
		}

		try await givenCharacterListRecovers()

		characterList { robot in
			robot.tapRetry()
			robot.verifyIsVisible()
			robot.verifyCharacterExists(identifier: 1)
		}
	}

	@MainActor
	func testSearchShowsEmptyStateAndClearSearchRestoresContent() async throws {
		// Given
		try await givenCharacterListWithEmptySearchSucceeds()

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
			robot.verifyEmptySearchStateIsVisible()
			robot.clearSearch()
			robot.verifyCharacterExists(identifier: 1)
		}
	}

	@MainActor
	func testNavigationFromListToDetailAndBackWithPullToRefresh() async throws {
		// Given
		try await givenCharacterListAndDetailSucceeds()

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
	func testDetailShowsErrorAndRetryLoadsContent() async throws {
		// Given
		try await givenCharacterDetailFailsButListSucceeds()

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
		}

		try await givenCharacterDetailRecovers()

		characterDetail { robot in
			robot.tapRetry()
			robot.verifyIsVisible()
		}
	}
}

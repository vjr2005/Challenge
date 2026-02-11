import XCTest

/// UI tests for the character list screen: error/retry, pagination, pull-to-refresh, and filters.
final class CharacterListUITests: UITestCase {
	@MainActor
	// swiftlint:disable:next function_body_length
	func testCharacterListErrorRetryPaginationRefreshFiltersAndDetailNavigation() async throws {
		// Given — all requests fail
		await givenAllRequestsFail()

		let url = try XCTUnwrap(URL(string: "challenge://character/list"))

		// When — launch with deep link to character list
		launch(deepLink: url)

		// Then — error screen is visible
		characterList { robot in
			robot.verifyErrorIsVisible()
		}

		// Recovery — configure pagination + empty search responses
		try await givenCharacterListWithPaginationAndEmptySearchSucceeds()

		// Retry — list loads with page 1
		characterList { robot in
			robot.tapRetry()
			robot.verifyIsVisible()
			robot.verifyCharacterExists(identifier: 1)
			robot.verifyCharacterDoesNotExist(identifier: 21)

			// Load more — page 2 appended
			robot.tapLoadMore()
			robot.verifyCharacterExists(identifier: 21)

			// Search for non-existent name — empty state
			robot.typeSearch(text: "NonExistent")
			robot.verifyEmptySearchStateIsVisible()

			// Cancel search — list reappears
			robot.cancelSearch()
			robot.verifyCharacterExists(identifier: 1)

			// Tap search field — recent searches appear
			robot.tapSearchField()
			robot.verifyRecentSearchExists(query: "NonExistent")

			// Tap recent search — empty results
			robot.tapRecentSearch(query: "NonExistent")
			robot.verifyEmptySearchStateIsVisible()

			// Clear search — recent searches reappear
			robot.clearSearch()
			robot.verifyRecentSearchExists(query: "NonExistent")

			// Delete recent search
			robot.deleteRecentSearch(query: "NonExistent")
			robot.verifyRecentSearchDoesNotExist(query: "NonExistent")

			// Cancel search — list reappears
			robot.cancelSearch()
			robot.verifyCharacterExists(identifier: 1)

			// Pull to refresh — back to page 1 only
			robot.pullToRefresh()
			robot.verifyCharacterExists(identifier: 1)
			robot.verifyCharacterDoesNotExist(identifier: 21)

			// Open filter
			robot.tapFilterButton()
		}

		// Filter — verify empty state
		characterFilter { robot in
			robot.verifyIsVisible()
			robot.verifyResetIsDisabled()

			// Fill all filter fields
			robot.tapStatusChip("Alive")
			robot.tapGenderChip("Female")
			robot.typeSpecies(text: "Human")
			robot.typeType(text: "Genetic")

			// Reset — form cleared
			robot.tapReset()
			robot.verifyResetIsDisabled()

			// Close filter
			robot.tapClose()
		}

		// Verify character list is visible after closing filter
		characterList { robot in
			robot.verifyIsVisible()

			// Reopen filter
			robot.tapFilterButton()
		}

		// Filter — select, deselect, then apply
		characterFilter { robot in
			robot.verifyIsVisible()
			robot.tapStatusChip("Alive")
			robot.tapStatusChip("Alive")
			robot.tapGenderChip("Male")
			robot.tapApply()
		}

		// Verify character list is visible after applying filter
		// Register detail route so tapping a character loads correctly
		try await givenCharacterDetailRecovers()

		characterList { robot in
			robot.verifyIsVisible()
			robot.tapCharacter(identifier: 1)
		}

		characterDetail { robot in
			robot.verifyIsVisible()
			robot.tapBack()
		}

		characterList { robot in
			robot.verifyIsVisible()
		}
	}
}

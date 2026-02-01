import XCTest

/// UI tests for the character browsing flow.
final class CharacterFlowUITests: UITestCase {
	@MainActor
	func testCharacterBrowsingFlow() throws {
		// Given
		let charactersData = Data.fixture("characters_response")
		let characterData = Data.fixture("character")
		let imageData = Data.stubAvatarImage

		stubServer.requestHandler = { path in
			if path.contains("/avatar/") {
				return .image(imageData)
			}
			if path.contains("/character/") {
				return .ok(characterData)
			}
			if path.contains("/character") {
				return .ok(charactersData)
			}
			return .notFound
		}

		// When
		launch()

		// Then
		home { robot in
			robot.verifyIsVisible()
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.tapCharacter(id: 1)
		}

		characterDetail { robot in
			robot.verifyIsVisible()
			robot.tapBack()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.tapBack()
		}

		home { robot in
			robot.verifyIsVisible()
		}
	}

	@MainActor
	func testCharacterSearchFlow() throws {
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

		// When
		launch()

		// Then
		home { robot in
			robot.verifyIsVisible()
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.typeSearch(text: "Rick")
			robot.verifyIsVisible()
		}
	}

	@MainActor
	func testCharacterSearchWithNoResultsShowsEmptyState() throws {
		// Given
		let charactersData = Data.fixture("characters_response")
		let emptyData = Data.fixture("characters_response_empty")
		let imageData = Data.stubAvatarImage

		stubServer.requestHandler = { path in
			if path.contains("/avatar/") {
				return .image(imageData)
			}
			if path.contains("/character") {
				// Return empty results when searching for non-matching term
				if path.contains("name=") {
					return .ok(emptyData)
				}
				return .ok(charactersData)
			}
			return .notFound
		}

		// When
		launch()

		// Then
		home { robot in
			robot.verifyIsVisible()
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.typeSearch(text: "ZZZZZNONEXISTENT")
			robot.verifyEmptyStateIsVisible()
		}
	}

	@MainActor
	func testCharacterListPagination() throws {
		// Given
		let page1Data = Data.fixture("characters_response")
		let page2Data = Data.fixture("characters_response_page_2")
		let imageData = Data.stubAvatarImage

		stubServer.requestHandler = { path in
			if path.contains("/avatar/") {
				return .image(imageData)
			}
			if path.contains("/character") {
				if path.contains("page=2") {
					return .ok(page2Data)
				}
				return .ok(page1Data)
			}
			return .notFound
		}

		// When
		launch()

		// Then
		home { robot in
			robot.verifyIsVisible()
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.verifyLoadMoreButtonExists()
			robot.tapLoadMore()
			robot.verifyIsVisible()
			// After loading more, character with id 21 should exist (first of page 2)
			robot.verifyCharacterExists(id: 21)
		}
	}

	@MainActor
	func testCharacterRowAccessibilityIdentifiersArePropagated() throws {
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

		// When
		launch()

		home { robot in
			robot.verifyIsVisible()
			robot.tapCharacterButton()
		}

		// Then - Verify DS accessibility identifiers are propagated correctly
		characterList { robot in
			robot.verifyIsVisible()
			robot.verifyRowTitleIdentifierExists(id: 1)
			robot.verifyRowImageIdentifierExists(id: 1)
			robot.verifyRowStatusIdentifierExists(id: 1)
		}
	}

	@MainActor
	func testCharacterListPullToRefresh() throws {
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

		// When
		launch()

		// Then
		home { robot in
			robot.verifyIsVisible()
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.pullToRefresh()
			robot.verifyIsVisible()
		}
	}
}

import XCTest

/// UI tests for the character browsing flow.
final class CharacterFlowUITests: UITestCase {
    @MainActor
    func testListPaginationLoadsMoreAndPullToRefreshResetsContent() throws {
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
        stubServer.requestHandler = { _ in
            .serverError
        }

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
        let charactersData = Data.fixture("characters_response")
        let emptyData = Data.fixture("characters_response_empty")
        let imageData = Data.stubAvatarImage

        stubServer.requestHandler = { path in
            if path.contains("/avatar/") {
                return .image(imageData)
            }
            if path.contains("/character") {
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
        let charactersData = Data.fixture("characters_response")
        let imageData = Data.stubAvatarImage

        stubServer.requestHandler = { path in
            if path.contains("/avatar/") {
                return .image(imageData)
            }
            if path.contains("/character/") {
                return .serverError
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

import Testing

@testable import ChallengeCharacter

struct CharacterListEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name")
    func screenViewedEventHasCorrectName() {
        // Given
        let sut = CharacterListEvent.screenViewed

        // Then
        #expect(sut.name == "character_list_viewed")
    }

    @Test("Screen viewed event has empty properties")
    func screenViewedEventHasEmptyProperties() {
        // Given
        let sut = CharacterListEvent.screenViewed

        // Then
        #expect(sut.properties == [:])
    }

    // MARK: - characterSelected

    @Test("Character selected event has correct name")
    func characterSelectedEventHasCorrectName() {
        // Given
        let sut = CharacterListEvent.characterSelected(identifier: 42)

        // Then
        #expect(sut.name == "character_selected")
    }

    @Test("Character selected event has identifier in properties")
    func characterSelectedEventHasIdentifierInProperties() {
        // Given
        let sut = CharacterListEvent.characterSelected(identifier: 42)

        // Then
        #expect(sut.properties == ["id": "42"])
    }

    // MARK: - searchPerformed

    @Test("Search performed event has correct name")
    func searchPerformedEventHasCorrectName() {
        // Given
        let sut = CharacterListEvent.searchPerformed(query: "Rick")

        // Then
        #expect(sut.name == "search_performed")
    }

    @Test("Search performed event has query in properties")
    func searchPerformedEventHasQueryInProperties() {
        // Given
        let sut = CharacterListEvent.searchPerformed(query: "Rick")

        // Then
        #expect(sut.properties == ["query": "Rick"])
    }

    // MARK: - retryButtonTapped

    @Test("Retry button tapped event has correct name")
    func retryButtonTappedEventHasCorrectName() {
        // Given
        let sut = CharacterListEvent.retryButtonTapped

        // Then
        #expect(sut.name == "character_list_retry_tapped")
    }

    @Test("Retry button tapped event has empty properties")
    func retryButtonTappedEventHasEmptyProperties() {
        // Given
        let sut = CharacterListEvent.retryButtonTapped

        // Then
        #expect(sut.properties == [:])
    }

    // MARK: - pullToRefreshTriggered

    @Test("Pull to refresh triggered event has correct name")
    func pullToRefreshTriggeredEventHasCorrectName() {
        // Given
        let sut = CharacterListEvent.pullToRefreshTriggered

        // Then
        #expect(sut.name == "character_list_pull_to_refresh")
    }

    @Test("Pull to refresh triggered event has empty properties")
    func pullToRefreshTriggeredEventHasEmptyProperties() {
        // Given
        let sut = CharacterListEvent.pullToRefreshTriggered

        // Then
        #expect(sut.properties == [:])
    }

    // MARK: - loadMoreButtonTapped

    @Test("Load more button tapped event has correct name")
    func loadMoreButtonTappedEventHasCorrectName() {
        // Given
        let sut = CharacterListEvent.loadMoreButtonTapped

        // Then
        #expect(sut.name == "character_list_load_more_tapped")
    }

    @Test("Load more button tapped event has empty properties")
    func loadMoreButtonTappedEventHasEmptyProperties() {
        // Given
        let sut = CharacterListEvent.loadMoreButtonTapped

        // Then
        #expect(sut.properties == [:])
    }

    // MARK: - advancedSearchButtonTapped

    @Test("Advanced search button tapped event has correct name")
    func advancedSearchButtonTappedEventHasCorrectName() {
        // Given
        let sut = CharacterListEvent.advancedSearchButtonTapped

        // Then
        #expect(sut.name == "character_list_advanced_search_tapped")
    }

    @Test("Advanced search button tapped event has empty properties")
    func advancedSearchButtonTappedEventHasEmptyProperties() {
        // Given
        let sut = CharacterListEvent.advancedSearchButtonTapped

        // Then
        #expect(sut.properties == [:])
    }

    // MARK: - fetchError

    @Test("Fetch error event has correct name")
    func fetchErrorEventHasCorrectName() {
        // Given
        let sut = CharacterListEvent.fetchError(description: "Load failed")

        // Then
        #expect(sut.name == "character_list_fetch_error")
    }

    @Test("Fetch error event has description in properties")
    func fetchErrorEventHasDescriptionInProperties() {
        // Given
        let sut = CharacterListEvent.fetchError(description: "Load failed")

        // Then
        #expect(sut.properties == ["description": "Load failed"])
    }

    // MARK: - refreshError

    @Test("Refresh error event has correct name")
    func refreshErrorEventHasCorrectName() {
        // Given
        let sut = CharacterListEvent.refreshError(description: "Refresh failed")

        // Then
        #expect(sut.name == "character_list_refresh_error")
    }

    @Test("Refresh error event has description in properties")
    func refreshErrorEventHasDescriptionInProperties() {
        // Given
        let sut = CharacterListEvent.refreshError(description: "Refresh failed")

        // Then
        #expect(sut.properties == ["description": "Refresh failed"])
    }

    // MARK: - loadMoreError

    @Test("Load more error event has correct name")
    func loadMoreErrorEventHasCorrectName() {
        // Given
        let sut = CharacterListEvent.loadMoreError(description: "Load more failed")

        // Then
        #expect(sut.name == "character_list_load_more_error")
    }

    @Test("Load more error event has description in properties")
    func loadMoreErrorEventHasDescriptionInProperties() {
        // Given
        let sut = CharacterListEvent.loadMoreError(description: "Load more failed")

        // Then
        #expect(sut.properties == ["description": "Load more failed"])
    }
}

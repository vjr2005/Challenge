import Testing

@testable import ChallengeCharacter

struct CharacterListEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name and empty properties")
    func screenViewedEvent() {
        // Given
        let sut = CharacterListEvent.screenViewed

        // Then
        #expect(sut.name == "character_list_viewed")
        #expect(sut.properties == [:])
    }

    // MARK: - characterSelected

    @Test("Character selected event has correct name and properties")
    func characterSelectedEvent() {
        // Given
        let sut = CharacterListEvent.characterSelected(identifier: 42)

        // Then
        #expect(sut.name == "character_selected")
        #expect(sut.properties == ["id": "42"])
    }

    // MARK: - searchPerformed

    @Test("Search performed event has correct name and properties")
    func searchPerformedEvent() {
        // Given
        let sut = CharacterListEvent.searchPerformed(query: "Rick")

        // Then
        #expect(sut.name == "search_performed")
        #expect(sut.properties == ["query": "Rick"])
    }

    // MARK: - retryButtonTapped

    @Test("Retry button tapped event has correct name and empty properties")
    func retryButtonTappedEvent() {
        // Given
        let sut = CharacterListEvent.retryButtonTapped

        // Then
        #expect(sut.name == "character_list_retry_tapped")
        #expect(sut.properties == [:])
    }

    // MARK: - pullToRefreshTriggered

    @Test("Pull to refresh triggered event has correct name and empty properties")
    func pullToRefreshTriggeredEvent() {
        // Given
        let sut = CharacterListEvent.pullToRefreshTriggered

        // Then
        #expect(sut.name == "character_list_pull_to_refresh")
        #expect(sut.properties == [:])
    }

    // MARK: - loadMoreButtonTapped

    @Test("Load more button tapped event has correct name and empty properties")
    func loadMoreButtonTappedEvent() {
        // Given
        let sut = CharacterListEvent.loadMoreButtonTapped

        // Then
        #expect(sut.name == "character_list_load_more_tapped")
        #expect(sut.properties == [:])
    }

    // MARK: - characterFilterButtonTapped

    @Test("Character filter button tapped event has correct name and empty properties")
    func characterFilterButtonTappedEvent() {
        // Given
        let sut = CharacterListEvent.characterFilterButtonTapped

        // Then
        #expect(sut.name == "character_list_character_filter_tapped")
        #expect(sut.properties == [:])
    }

    // MARK: - fetchError

    @Test("Fetch error event has correct name and properties")
    func fetchErrorEvent() {
        // Given
        let sut = CharacterListEvent.fetchError(description: "Load failed")

        // Then
        #expect(sut.name == "character_list_fetch_error")
        #expect(sut.properties == ["description": "Load failed"])
    }

    // MARK: - refreshError

    @Test("Refresh error event has correct name and properties")
    func refreshErrorEvent() {
        // Given
        let sut = CharacterListEvent.refreshError(description: "Refresh failed")

        // Then
        #expect(sut.name == "character_list_refresh_error")
        #expect(sut.properties == ["description": "Refresh failed"])
    }

    // MARK: - loadMoreError

    @Test("Load more error event has correct name and properties")
    func loadMoreErrorEvent() {
        // Given
        let sut = CharacterListEvent.loadMoreError(description: "Load more failed")

        // Then
        #expect(sut.name == "character_list_load_more_error")
        #expect(sut.properties == ["description": "Load more failed"])
    }
}

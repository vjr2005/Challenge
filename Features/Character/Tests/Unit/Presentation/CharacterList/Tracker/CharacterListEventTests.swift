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
}

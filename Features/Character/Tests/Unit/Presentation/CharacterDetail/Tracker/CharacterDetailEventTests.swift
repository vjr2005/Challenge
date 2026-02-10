import Testing

@testable import ChallengeCharacter

struct CharacterDetailEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name")
    func screenViewedEventHasCorrectName() {
        // Given
        let sut = CharacterDetailEvent.screenViewed(identifier: 42)

        // Then
        #expect(sut.name == "character_detail_viewed")
    }

    @Test("Screen viewed event has identifier in properties")
    func screenViewedEventHasIdentifierInProperties() {
        // Given
        let sut = CharacterDetailEvent.screenViewed(identifier: 42)

        // Then
        #expect(sut.properties == ["id": "42"])
    }

    // MARK: - retryButtonTapped

    @Test("Retry button tapped event has correct name")
    func retryButtonTappedEventHasCorrectName() {
        // Given
        let sut = CharacterDetailEvent.retryButtonTapped

        // Then
        #expect(sut.name == "character_detail_retry_tapped")
    }

    @Test("Retry button tapped event has empty properties")
    func retryButtonTappedEventHasEmptyProperties() {
        // Given
        let sut = CharacterDetailEvent.retryButtonTapped

        // Then
        #expect(sut.properties == [:])
    }

    // MARK: - pullToRefreshTriggered

    @Test("Pull to refresh triggered event has correct name")
    func pullToRefreshTriggeredEventHasCorrectName() {
        // Given
        let sut = CharacterDetailEvent.pullToRefreshTriggered

        // Then
        #expect(sut.name == "character_detail_pull_to_refresh")
    }

    @Test("Pull to refresh triggered event has empty properties")
    func pullToRefreshTriggeredEventHasEmptyProperties() {
        // Given
        let sut = CharacterDetailEvent.pullToRefreshTriggered

        // Then
        #expect(sut.properties == [:])
    }

    // MARK: - backButtonTapped

    @Test("Back button tapped event has correct name")
    func backButtonTappedEventHasCorrectName() {
        // Given
        let sut = CharacterDetailEvent.backButtonTapped

        // Then
        #expect(sut.name == "character_detail_back_tapped")
    }

    @Test("Back button tapped event has empty properties")
    func backButtonTappedEventHasEmptyProperties() {
        // Given
        let sut = CharacterDetailEvent.backButtonTapped

        // Then
        #expect(sut.properties == [:])
    }

    // MARK: - episodesButtonTapped

    @Test("Episodes button tapped event has correct name")
    func episodesButtonTappedEventHasCorrectName() {
        // Given
        let sut = CharacterDetailEvent.episodesButtonTapped(identifier: 42)

        // Then
        #expect(sut.name == "character_detail_episodes_tapped")
    }

    @Test("Episodes button tapped event has identifier in properties")
    func episodesButtonTappedEventHasIdentifierInProperties() {
        // Given
        let sut = CharacterDetailEvent.episodesButtonTapped(identifier: 42)

        // Then
        #expect(sut.properties == ["id": "42"])
    }

    // MARK: - loadError

    @Test("Load error event has correct name")
    func loadErrorEventHasCorrectName() {
        // Given
        let sut = CharacterDetailEvent.loadError(description: "Load failed")

        // Then
        #expect(sut.name == "character_detail_load_error")
    }

    @Test("Load error event has description in properties")
    func loadErrorEventHasDescriptionInProperties() {
        // Given
        let sut = CharacterDetailEvent.loadError(description: "Load failed")

        // Then
        #expect(sut.properties == ["description": "Load failed"])
    }

    // MARK: - refreshError

    @Test("Refresh error event has correct name")
    func refreshErrorEventHasCorrectName() {
        // Given
        let sut = CharacterDetailEvent.refreshError(description: "Refresh failed")

        // Then
        #expect(sut.name == "character_detail_refresh_error")
    }

    @Test("Refresh error event has description in properties")
    func refreshErrorEventHasDescriptionInProperties() {
        // Given
        let sut = CharacterDetailEvent.refreshError(description: "Refresh failed")

        // Then
        #expect(sut.properties == ["description": "Refresh failed"])
    }
}

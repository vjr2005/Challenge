import Testing

@testable import ChallengeCharacter

struct CharacterDetailEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name and properties")
    func screenViewedEvent() {
        // Given
        let sut = CharacterDetailEvent.screenViewed(identifier: 42)

        // Then
        #expect(sut.name == "character_detail_viewed")
        #expect(sut.properties == ["id": "42"])
    }

    // MARK: - retryButtonTapped

    @Test("Retry button tapped event has correct name and empty properties")
    func retryButtonTappedEvent() {
        // Given
        let sut = CharacterDetailEvent.retryButtonTapped

        // Then
        #expect(sut.name == "character_detail_retry_tapped")
        #expect(sut.properties == [:])
    }

    // MARK: - pullToRefreshTriggered

    @Test("Pull to refresh triggered event has correct name and empty properties")
    func pullToRefreshTriggeredEvent() {
        // Given
        let sut = CharacterDetailEvent.pullToRefreshTriggered

        // Then
        #expect(sut.name == "character_detail_pull_to_refresh")
        #expect(sut.properties == [:])
    }

    // MARK: - episodesButtonTapped

    @Test("Episodes button tapped event has correct name and properties")
    func episodesButtonTappedEvent() {
        // Given
        let sut = CharacterDetailEvent.episodesButtonTapped(identifier: 42)

        // Then
        #expect(sut.name == "character_detail_episodes_tapped")
        #expect(sut.properties == ["id": "42"])
    }

    // MARK: - loadError

    @Test("Load error event has correct name and properties")
    func loadErrorEvent() {
        // Given
        let sut = CharacterDetailEvent.loadError(description: "Load failed")

        // Then
        #expect(sut.name == "character_detail_load_error")
        #expect(sut.properties == ["description": "Load failed"])
    }

    // MARK: - refreshError

    @Test("Refresh error event has correct name and properties")
    func refreshErrorEvent() {
        // Given
        let sut = CharacterDetailEvent.refreshError(description: "Refresh failed")

        // Then
        #expect(sut.name == "character_detail_refresh_error")
        #expect(sut.properties == ["description": "Refresh failed"])
    }
}

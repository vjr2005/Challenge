import Testing

@testable import ChallengeEpisode

struct CharacterEpisodesEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name and properties")
    func screenViewedEvent() {
        // Given
        let event = CharacterEpisodesEvent.screenViewed(characterIdentifier: 42)

        // When
        let name = event.name
        let properties = event.properties

        // Then
        #expect(name == "character_episodes_viewed")
        #expect(properties == ["character_id": "42"])
    }

    // MARK: - retryButtonTapped

    @Test("Retry button tapped event has correct name and empty properties")
    func retryButtonTappedEvent() {
        // Given
        let event = CharacterEpisodesEvent.retryButtonTapped

        // When
        let name = event.name
        let properties = event.properties

        // Then
        #expect(name == "character_episodes_retry_tapped")
        #expect(properties.isEmpty)
    }

    // MARK: - pullToRefreshTriggered

    @Test("Pull to refresh triggered event has correct name and empty properties")
    func pullToRefreshTriggeredEvent() {
        // Given
        let event = CharacterEpisodesEvent.pullToRefreshTriggered

        // When
        let name = event.name
        let properties = event.properties

        // Then
        #expect(name == "character_episodes_pull_to_refresh")
        #expect(properties.isEmpty)
    }

    // MARK: - characterAvatarTapped

    @Test("Character avatar tapped event has correct name and properties")
    func characterAvatarTappedEvent() {
        // Given
        let event = CharacterEpisodesEvent.characterAvatarTapped(identifier: 42)

        // When
        let name = event.name
        let properties = event.properties

        // Then
        #expect(name == "character_episodes_character_avatar_tapped")
        #expect(properties == ["character_id": "42"])
    }

    // MARK: - loadError

    @Test("Load error event has correct name and properties")
    func loadErrorEvent() {
        // Given
        let event = CharacterEpisodesEvent.loadError(description: "network error")

        // When
        let name = event.name
        let properties = event.properties

        // Then
        #expect(name == "character_episodes_load_error")
        #expect(properties == ["description": "network error"])
    }

    // MARK: - refreshError

    @Test("Refresh error event has correct name and properties")
    func refreshErrorEvent() {
        // Given
        let event = CharacterEpisodesEvent.refreshError(description: "timeout")

        // When
        let name = event.name
        let properties = event.properties

        // Then
        #expect(name == "character_episodes_refresh_error")
        #expect(properties == ["description": "timeout"])
    }
}

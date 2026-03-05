import Testing

@testable import ChallengeEpisode

struct CharacterEpisodesEventTests {
    // MARK: - screenViewed

    @Test("Screen viewed event has correct name and properties")
    func screenViewedEvent() {
        #expect(CharacterEpisodesEvent.screenViewed(characterIdentifier: 42).name == "character_episodes_viewed")
        #expect(CharacterEpisodesEvent.screenViewed(characterIdentifier: 42).properties == ["character_id": "42"])
    }

    // MARK: - retryButtonTapped

    @Test("Retry button tapped event has correct name and empty properties")
    func retryButtonTappedEvent() {
        #expect(CharacterEpisodesEvent.retryButtonTapped.name == "character_episodes_retry_tapped")
        #expect(CharacterEpisodesEvent.retryButtonTapped.properties == [:])
    }

    // MARK: - pullToRefreshTriggered

    @Test("Pull to refresh triggered event has correct name and empty properties")
    func pullToRefreshTriggeredEvent() {
        #expect(CharacterEpisodesEvent.pullToRefreshTriggered.name == "character_episodes_pull_to_refresh")
        #expect(CharacterEpisodesEvent.pullToRefreshTriggered.properties == [:])
    }

    // MARK: - characterAvatarTapped

    @Test("Character avatar tapped event has correct name and properties")
    func characterAvatarTappedEvent() {
        #expect(CharacterEpisodesEvent.characterAvatarTapped(identifier: 42).name == "character_episodes_character_avatar_tapped")
        #expect(CharacterEpisodesEvent.characterAvatarTapped(identifier: 42).properties == ["character_id": "42"])
    }

    // MARK: - loadError

    @Test("Load error event has correct name and properties")
    func loadErrorEvent() {
        #expect(CharacterEpisodesEvent.loadError(description: "network error").name == "character_episodes_load_error")
        #expect(CharacterEpisodesEvent.loadError(description: "network error").properties == ["description": "network error"])
    }

    // MARK: - refreshError

    @Test("Refresh error event has correct name and properties")
    func refreshErrorEvent() {
        #expect(CharacterEpisodesEvent.refreshError(description: "timeout").name == "character_episodes_refresh_error")
        #expect(CharacterEpisodesEvent.refreshError(description: "timeout").properties == ["description": "timeout"])
    }
}

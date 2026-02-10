import Testing

@testable import ChallengeEpisode

struct CharacterEpisodesEventTests {
	// MARK: - Screen Viewed

	@Test("Screen viewed has correct name")
	func screenViewedHasCorrectName() {
		#expect(CharacterEpisodesEvent.screenViewed(characterIdentifier: 1).name == "character_episodes_viewed")
	}

	@Test("Screen viewed has character id property")
	func screenViewedHasCharacterIdProperty() {
		#expect(CharacterEpisodesEvent.screenViewed(characterIdentifier: 42).properties == ["character_id": "42"])
	}

	// MARK: - Retry Button Tapped

	@Test("Retry button tapped has correct name")
	func retryButtonTappedHasCorrectName() {
		#expect(CharacterEpisodesEvent.retryButtonTapped.name == "character_episodes_retry_tapped")
	}

	@Test("Retry button tapped has empty properties")
	func retryButtonTappedHasEmptyProperties() {
		#expect(CharacterEpisodesEvent.retryButtonTapped.properties == [:])
	}

	// MARK: - Pull To Refresh Triggered

	@Test("Pull to refresh triggered has correct name")
	func pullToRefreshTriggeredHasCorrectName() {
		#expect(CharacterEpisodesEvent.pullToRefreshTriggered.name == "character_episodes_pull_to_refresh")
	}

	@Test("Pull to refresh triggered has empty properties")
	func pullToRefreshTriggeredHasEmptyProperties() {
		#expect(CharacterEpisodesEvent.pullToRefreshTriggered.properties == [:])
	}

	// MARK: - Character Avatar Tapped

	@Test("Character avatar tapped has correct name")
	func characterAvatarTappedHasCorrectName() {
		#expect(CharacterEpisodesEvent.characterAvatarTapped(identifier: 1).name == "character_episodes_character_avatar_tapped")
	}

	@Test("Character avatar tapped has character id property")
	func characterAvatarTappedHasCharacterIdProperty() {
		#expect(CharacterEpisodesEvent.characterAvatarTapped(identifier: 42).properties == ["character_id": "42"])
	}

	// MARK: - Load Error

	@Test("Load error has correct name")
	func loadErrorHasCorrectName() {
		#expect(CharacterEpisodesEvent.loadError(description: "error").name == "character_episodes_load_error")
	}

	@Test("Load error has description property")
	func loadErrorHasDescriptionProperty() {
		#expect(CharacterEpisodesEvent.loadError(description: "network error").properties == ["description": "network error"])
	}

	// MARK: - Refresh Error

	@Test("Refresh error has correct name")
	func refreshErrorHasCorrectName() {
		#expect(CharacterEpisodesEvent.refreshError(description: "error").name == "character_episodes_refresh_error")
	}

	@Test("Refresh error has description property")
	func refreshErrorHasDescriptionProperty() {
		#expect(CharacterEpisodesEvent.refreshError(description: "timeout").properties == ["description": "timeout"])
	}
}

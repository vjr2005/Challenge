import Testing

@testable import ChallengeEpisode

@Suite
struct CharacterEpisodesViewStateTests {
	// MARK: - Equatable

	@Test("Different states are not equal")
	func differentStatesAreNotEqual() {
		// Given
		let idle = CharacterEpisodesViewState.idle
		let loading = CharacterEpisodesViewState.loading

		// Then
		#expect((idle == loading) == false)
	}
}

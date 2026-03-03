import Testing

@testable import ChallengeEpisode

@Suite
struct CharacterEpisodesViewStateTests {
	// MARK: - Equatable

	@Test("Same states are equal", arguments: [
		(CharacterEpisodesViewState.idle, CharacterEpisodesViewState.idle),
		(.loading, .loading),
		(.loaded(.stub()), .loaded(.stub())),
		(.error(.loadFailed()), .error(.loadFailed()))
	])
	func sameStatesAreEqual(lhs: CharacterEpisodesViewState, rhs: CharacterEpisodesViewState) {
		#expect(lhs == rhs)
	}

	@Test("Loaded states with different values are not equal")
	func loadedStatesWithDifferentValuesAreNotEqual() {
		#expect(CharacterEpisodesViewState.loaded(.stub(id: 1)) != .loaded(.stub(id: 2)))
	}

	@Test("Different states are not equal", arguments: [
		(CharacterEpisodesViewState.idle, CharacterEpisodesViewState.loading),
		(.idle, .loaded(.stub())),
		(.idle, .error(.loadFailed())),
		(.loading, .loaded(.stub())),
		(.loading, .error(.loadFailed())),
		(.loaded(.stub()), .error(.loadFailed()))
	])
	func differentStatesAreNotEqual(lhs: CharacterEpisodesViewState, rhs: CharacterEpisodesViewState) {
		#expect(lhs != rhs)
	}
}

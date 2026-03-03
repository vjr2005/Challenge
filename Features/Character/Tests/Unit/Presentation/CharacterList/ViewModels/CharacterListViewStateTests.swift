import Testing

@testable import ChallengeCharacter

@Suite
struct CharacterListViewStateTests {
	// MARK: - isSearchAvailable

	@Test("isSearchAvailable returns true", arguments: [
		CharacterListViewState.loaded(.stub()),
		.emptySearch
	])
	func isSearchAvailableReturnsTrue(state: CharacterListViewState) {
		#expect(state.isSearchAvailable == true)
	}

	@Test("isSearchAvailable returns false", arguments: [
		CharacterListViewState.idle,
		.loading,
		.empty,
		.error(.loadFailed())
	])
	func isSearchAvailableReturnsFalse(state: CharacterListViewState) {
		#expect(state.isSearchAvailable == false)
	}
}

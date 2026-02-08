import Testing

@testable import ChallengeCharacter

@Suite
struct CharacterListViewStateTests {
	// MARK: - isSearchAvailable

	@Test("isSearchAvailable returns true for loaded state")
	func isSearchAvailableReturnsTrueForLoadedState() {
		// Given
		let sut = CharacterListViewState.loaded(.stub())

		// When
		let result = sut.isSearchAvailable

		// Then
		#expect(result == true)
	}

	@Test("isSearchAvailable returns true for emptySearch state")
	func isSearchAvailableReturnsTrueForEmptySearchState() {
		// Given
		let sut = CharacterListViewState.emptySearch

		// When
		let result = sut.isSearchAvailable

		// Then
		#expect(result == true)
	}

	@Test("isSearchAvailable returns false for idle state")
	func isSearchAvailableReturnsFalseForIdleState() {
		// Given
		let sut = CharacterListViewState.idle

		// When
		let result = sut.isSearchAvailable

		// Then
		#expect(result == false)
	}

	@Test("isSearchAvailable returns false for loading state")
	func isSearchAvailableReturnsFalseForLoadingState() {
		// Given
		let sut = CharacterListViewState.loading

		// When
		let result = sut.isSearchAvailable

		// Then
		#expect(result == false)
	}

	@Test("isSearchAvailable returns false for empty state")
	func isSearchAvailableReturnsFalseForEmptyState() {
		// Given
		let sut = CharacterListViewState.empty

		// When
		let result = sut.isSearchAvailable

		// Then
		#expect(result == false)
	}

	@Test("isSearchAvailable returns false for error state")
	func isSearchAvailableReturnsFalseForErrorState() {
		// Given
		let sut = CharacterListViewState.error(.loadFailed())

		// When
		let result = sut.isSearchAvailable

		// Then
		#expect(result == false)
	}
}

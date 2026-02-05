import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct RecentSearchesLocalDataSourceTests {
	// MARK: - Properties

	private let sut: RecentSearchesLocalDataSource
	private let userDefaults: UserDefaults

	// MARK: - Initialization

	init() {
		let suiteName = "RecentSearchesLocalDataSourceTests.\(UUID().uuidString)"
		let userDefaults = UserDefaults(suiteName: suiteName)
		self.userDefaults = userDefaults ?? .standard
		sut = RecentSearchesLocalDataSource(userDefaults: self.userDefaults)
	}

	// MARK: - getRecentSearches

	@Test("Empty state returns empty array")
	func emptyStateReturnsEmptyArray() {
		// When
		let result = sut.getRecentSearches()

		// Then
		#expect(result == [])
	}

	// MARK: - saveSearch

	@Test("Single save and retrieve returns the saved query")
	func singleSaveAndRetrieve() {
		// When
		sut.saveSearch("Rick")

		// Then
		#expect(sut.getRecentSearches() == ["Rick"])
	}

	@Test("Most recent search appears first")
	func mostRecentFirstOrdering() {
		// Given
		sut.saveSearch("Rick")
		sut.saveSearch("Morty")

		// When
		let result = sut.getRecentSearches()

		// Then
		#expect(result == ["Morty", "Rick"])
	}

	@Test("Case-insensitive deduplication keeps latest casing")
	func caseInsensitiveDeduplication() {
		// Given
		sut.saveSearch("Rick")

		// When
		sut.saveSearch("rick")

		// Then
		#expect(sut.getRecentSearches() == ["rick"])
	}

	@Test("Maximum five searches stored")
	func maxFiveLimit() {
		// Given
		for index in 1...6 {
			sut.saveSearch("query\(index)")
		}

		// When
		let result = sut.getRecentSearches()

		// Then
		#expect(result.count == 5)
		#expect(result == ["query6", "query5", "query4", "query3", "query2"])
	}

	@Test("Re-searching existing entry moves it to front")
	func reSearchMovesToFront() {
		// Given
		sut.saveSearch("Rick")
		sut.saveSearch("Morty")
		sut.saveSearch("Summer")

		// When
		sut.saveSearch("Rick")

		// Then
		#expect(sut.getRecentSearches() == ["Rick", "Summer", "Morty"])
	}

	@Test("Persists across DataSource instances with same UserDefaults suite")
	func persistsAcrossInstances() {
		// Given
		sut.saveSearch("Rick")

		// When
		let otherInstance = RecentSearchesLocalDataSource(userDefaults: userDefaults)
		let result = otherInstance.getRecentSearches()

		// Then
		#expect(result == ["Rick"])
	}

	// MARK: - deleteSearch

	@Test("Delete removes existing search")
	func deleteRemovesExistingSearch() {
		// Given
		sut.saveSearch("Rick")
		sut.saveSearch("Morty")

		// When
		sut.deleteSearch("Rick")

		// Then
		#expect(sut.getRecentSearches() == ["Morty"])
	}

	@Test("Delete is case-insensitive")
	func deleteIsCaseInsensitive() {
		// Given
		sut.saveSearch("Rick")

		// When
		sut.deleteSearch("rick")

		// Then
		#expect(sut.getRecentSearches() == [])
	}

	@Test("Delete non-existing search does not modify list")
	func deleteNonExistingSearchDoesNotModifyList() {
		// Given
		sut.saveSearch("Rick")

		// When
		sut.deleteSearch("Morty")

		// Then
		#expect(sut.getRecentSearches() == ["Rick"])
	}
}

import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct RecentSearchesUserDefaultsDataSourceTests {
	// MARK: - Properties

	private let sut: RecentSearchesUserDefaultsDataSource
	private nonisolated(unsafe) let userDefaults: UserDefaults

	// MARK: - Initialization

	init() {
		let suiteName = "RecentSearchesUserDefaultsDataSourceTests.\(UUID().uuidString)"
		let userDefaults = UserDefaults(suiteName: suiteName)
		self.userDefaults = userDefaults ?? .standard
		sut = RecentSearchesUserDefaultsDataSource(userDefaults: self.userDefaults)
	}

	// MARK: - getRecentSearches

	@Test("Empty state returns empty array")
	func emptyStateReturnsEmptyArray() async {
		// When
		let result = await sut.getRecentSearches()

		// Then
		#expect(result == [])
	}

	// MARK: - saveSearch

	@Test("Single save and retrieve returns the saved query")
	func singleSaveAndRetrieve() async {
		// When
		await sut.saveSearch("Rick")

		// Then
		let result = await sut.getRecentSearches()
		#expect(result == ["Rick"])
	}

	@Test("Most recent search appears first")
	func mostRecentFirstOrdering() async {
		// Given
		await sut.saveSearch("Rick")
		await sut.saveSearch("Morty")

		// When
		let result = await sut.getRecentSearches()

		// Then
		#expect(result == ["Morty", "Rick"])
	}

	@Test("Case-insensitive deduplication keeps latest casing")
	func caseInsensitiveDeduplication() async {
		// Given
		await sut.saveSearch("Rick")

		// When
		await sut.saveSearch("rick")

		// Then
		let result = await sut.getRecentSearches()
		#expect(result == ["rick"])
	}

	@Test("Maximum five searches stored")
	func maxFiveLimit() async {
		// Given
		for index in 1...6 {
			await sut.saveSearch("query\(index)")
		}

		// When
		let result = await sut.getRecentSearches()

		// Then
		#expect(result.count == 5)
		#expect(result == ["query6", "query5", "query4", "query3", "query2"])
	}

	@Test("Re-searching existing entry moves it to front")
	func reSearchMovesToFront() async {
		// Given
		await sut.saveSearch("Rick")
		await sut.saveSearch("Morty")
		await sut.saveSearch("Summer")

		// When
		await sut.saveSearch("Rick")

		// Then
		let result = await sut.getRecentSearches()
		#expect(result == ["Rick", "Summer", "Morty"])
	}

	@Test("Persists across DataSource instances with same UserDefaults suite")
	func persistsAcrossInstances() async {
		// Given
		await sut.saveSearch("Rick")

		// When
		let otherInstance = RecentSearchesUserDefaultsDataSource(userDefaults: userDefaults)
		let result = await otherInstance.getRecentSearches()

		// Then
		#expect(result == ["Rick"])
	}

	// MARK: - deleteSearch

	@Test("Delete removes existing search")
	func deleteRemovesExistingSearch() async {
		// Given
		await sut.saveSearch("Rick")
		await sut.saveSearch("Morty")

		// When
		await sut.deleteSearch("Rick")

		// Then
		let result = await sut.getRecentSearches()
		#expect(result == ["Morty"])
	}

	@Test("Delete is case-insensitive")
	func deleteIsCaseInsensitive() async {
		// Given
		await sut.saveSearch("Rick")

		// When
		await sut.deleteSearch("rick")

		// Then
		let result = await sut.getRecentSearches()
		#expect(result == [])
	}

	@Test("Delete non-existing search does not modify list")
	func deleteNonExistingSearchDoesNotModifyList() async {
		// Given
		await sut.saveSearch("Rick")

		// When
		await sut.deleteSearch("Morty")

		// Then
		let result = await sut.getRecentSearches()
		#expect(result == ["Rick"])
	}
}

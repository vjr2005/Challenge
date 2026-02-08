import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct RecentSearchesRepositoryTests {
	// MARK: - Properties

	private let dataSourceMock = RecentSearchesLocalDataSourceMock()
	private let sut: RecentSearchesRepository

	// MARK: - Initialization

	init() {
		sut = RecentSearchesRepository(localDataSource: dataSourceMock)
	}

	// MARK: - Get Recent Searches

	@Test("Get recent searches delegates to data source")
	func getRecentSearchesDelegatesToDataSource() {
		// Given
		dataSourceMock.searches = ["Rick", "Morty"]

		// When
		let result = sut.getRecentSearches()

		// Then
		#expect(result == ["Rick", "Morty"])
		#expect(dataSourceMock.getRecentSearchesCallCount == 1)
	}

	// MARK: - Save Search

	@Test("Save search delegates to data source with correct query")
	func saveSearchDelegatesToDataSource() {
		// When
		sut.saveSearch("Rick")

		// Then
		#expect(dataSourceMock.saveSearchCallCount == 1)
		#expect(dataSourceMock.lastSavedQuery == "Rick")
	}

	// MARK: - Delete Search

	@Test("Delete search delegates to data source with correct query")
	func deleteSearchDelegatesToDataSource() {
		// When
		sut.deleteSearch("Morty")

		// Then
		#expect(dataSourceMock.deleteSearchCallCount == 1)
		#expect(dataSourceMock.lastDeletedQuery == "Morty")
	}
}

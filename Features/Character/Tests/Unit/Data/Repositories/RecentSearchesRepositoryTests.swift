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
	func getRecentSearchesDelegatesToDataSource() async {
		// Given
		await dataSourceMock.setSearches(["Rick", "Morty"])

		// When
		let result = await sut.getRecentSearches()

		// Then
		#expect(result == ["Rick", "Morty"])
		let callCount = await dataSourceMock.getRecentSearchesCallCount
		#expect(callCount == 1)
	}

	// MARK: - Save Search

	@Test("Save search delegates to data source with correct query")
	func saveSearchDelegatesToDataSource() async {
		// When
		await sut.saveSearch("Rick")

		// Then
		let callCount = await dataSourceMock.saveSearchCallCount
		#expect(callCount == 1)
		let lastSavedQuery = await dataSourceMock.lastSavedQuery
		#expect(lastSavedQuery == "Rick")
	}

	// MARK: - Delete Search

	@Test("Delete search delegates to data source with correct query")
	func deleteSearchDelegatesToDataSource() async {
		// When
		await sut.deleteSearch("Morty")

		// Then
		let callCount = await dataSourceMock.deleteSearchCallCount
		#expect(callCount == 1)
		let lastDeletedQuery = await dataSourceMock.lastDeletedQuery
		#expect(lastDeletedQuery == "Morty")
	}
}

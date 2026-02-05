import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct GetRecentSearchesUseCaseTests {
	// MARK: - Properties

	private let dataSourceMock = RecentSearchesLocalDataSourceMock()
	private let sut: GetRecentSearchesUseCase

	// MARK: - Initialization

	init() {
		sut = GetRecentSearchesUseCase(dataSource: dataSourceMock)
	}

	// MARK: - Execute

	@Test("Execute returns searches from data source")
	func executeReturnsSearches() {
		// Given
		dataSourceMock.searches = ["Rick", "Morty"]

		// When
		let result = sut.execute()

		// Then
		#expect(result == ["Rick", "Morty"])
	}

	@Test("Execute returns empty array when no searches exist")
	func executeReturnsEmptyWhenNoneExist() {
		// When
		let result = sut.execute()

		// Then
		#expect(result == [])
	}

	@Test("Execute calls data source exactly once")
	func executeCallsDataSourceOnce() {
		// When
		_ = sut.execute()

		// Then
		#expect(dataSourceMock.getRecentSearchesCallCount == 1)
	}
}

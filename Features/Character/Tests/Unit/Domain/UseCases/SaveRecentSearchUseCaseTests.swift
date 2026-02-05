import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct SaveRecentSearchUseCaseTests {
	// MARK: - Properties

	private let dataSourceMock = RecentSearchesLocalDataSourceMock()
	private let sut: SaveRecentSearchUseCase

	// MARK: - Initialization

	init() {
		sut = SaveRecentSearchUseCase(dataSource: dataSourceMock)
	}

	// MARK: - Execute

	@Test("Execute calls data source with correct query")
	func executeCallsDataSourceWithCorrectQuery() {
		// When
		sut.execute(query: "Rick")

		// Then
		#expect(dataSourceMock.lastSavedQuery == "Rick")
	}

	@Test("Execute calls data source exactly once")
	func executeCallsDataSourceOnce() {
		// When
		sut.execute(query: "Morty")

		// Then
		#expect(dataSourceMock.saveSearchCallCount == 1)
	}
}

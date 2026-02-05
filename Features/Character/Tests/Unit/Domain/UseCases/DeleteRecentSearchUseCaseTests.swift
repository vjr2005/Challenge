import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct DeleteRecentSearchUseCaseTests {
	// MARK: - Properties

	private let dataSourceMock = RecentSearchesLocalDataSourceMock()
	private let sut: DeleteRecentSearchUseCase

	// MARK: - Initialization

	init() {
		sut = DeleteRecentSearchUseCase(dataSource: dataSourceMock)
	}

	// MARK: - Execute

	@Test("Execute calls data source with correct query")
	func executeCallsDataSourceWithCorrectQuery() {
		// When
		sut.execute(query: "Rick")

		// Then
		#expect(dataSourceMock.lastDeletedQuery == "Rick")
	}

	@Test("Execute calls data source exactly once")
	func executeCallsDataSourceOnce() {
		// When
		sut.execute(query: "Morty")

		// Then
		#expect(dataSourceMock.deleteSearchCallCount == 1)
	}
}

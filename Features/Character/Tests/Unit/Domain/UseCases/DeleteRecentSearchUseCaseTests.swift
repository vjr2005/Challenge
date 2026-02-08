import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct DeleteRecentSearchUseCaseTests {
	// MARK: - Properties

	private let repositoryMock = RecentSearchesRepositoryMock()
	private let sut: DeleteRecentSearchUseCase

	// MARK: - Initialization

	init() {
		sut = DeleteRecentSearchUseCase(repository: repositoryMock)
	}

	// MARK: - Execute

	@Test("Execute calls repository with correct query")
	func executeCallsRepositoryWithCorrectQuery() {
		// When
		sut.execute(query: "Rick")

		// Then
		#expect(repositoryMock.lastDeletedQuery == "Rick")
	}

	@Test("Execute calls repository exactly once")
	func executeCallsRepositoryOnce() {
		// When
		sut.execute(query: "Morty")

		// Then
		#expect(repositoryMock.deleteSearchCallCount == 1)
	}
}

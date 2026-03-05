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

	@Test("Execute deletes the given query from repository")
	func executeDeletesQuery() async {
		// When
		await sut.execute(query: "Rick")

		// Then
		#expect(repositoryMock.deleteSearchCallCount == 1)
		#expect(repositoryMock.lastDeletedQuery == "Rick")
	}
}

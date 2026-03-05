import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct SaveRecentSearchUseCaseTests {
	// MARK: - Properties

	private let repositoryMock = RecentSearchesRepositoryMock()
	private let sut: SaveRecentSearchUseCase

	// MARK: - Initialization

	init() {
		sut = SaveRecentSearchUseCase(repository: repositoryMock)
	}

	// MARK: - Execute

	@Test("Execute saves the given query to repository")
	func executeSavesQuery() async {
		// When
		await sut.execute(query: "Rick")

		// Then
		#expect(repositoryMock.saveSearchCallCount == 1)
		#expect(repositoryMock.lastSavedQuery == "Rick")
	}
}

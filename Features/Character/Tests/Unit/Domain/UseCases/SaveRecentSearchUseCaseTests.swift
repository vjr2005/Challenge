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

	@Test("Execute calls repository with correct query")
	func executeCallsRepositoryWithCorrectQuery() async {
		// When
		await sut.execute(query: "Rick")

		// Then
		#expect(repositoryMock.lastSavedQuery == "Rick")
	}

	@Test("Execute calls repository exactly once")
	func executeCallsRepositoryOnce() async {
		// When
		await sut.execute(query: "Morty")

		// Then
		#expect(repositoryMock.saveSearchCallCount == 1)
	}
}

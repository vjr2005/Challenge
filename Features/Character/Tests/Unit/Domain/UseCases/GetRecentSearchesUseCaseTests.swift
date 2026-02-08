import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct GetRecentSearchesUseCaseTests {
	// MARK: - Properties

	private let repositoryMock = RecentSearchesRepositoryMock()
	private let sut: GetRecentSearchesUseCase

	// MARK: - Initialization

	init() {
		sut = GetRecentSearchesUseCase(repository: repositoryMock)
	}

	// MARK: - Execute

	@Test("Execute returns searches from repository")
	func executeReturnsSearches() {
		// Given
		repositoryMock.searches = ["Rick", "Morty"]

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

	@Test("Execute calls repository exactly once")
	func executeCallsRepositoryOnce() {
		// When
		_ = sut.execute()

		// Then
		#expect(repositoryMock.getRecentSearchesCallCount == 1)
	}
}

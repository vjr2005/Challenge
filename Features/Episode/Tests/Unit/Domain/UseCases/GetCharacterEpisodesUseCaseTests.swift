import ChallengeCore
import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct GetCharacterEpisodesUseCaseTests {
	// MARK: - Properties

	private let repositoryMock = EpisodeRepositoryMock()
	private let sut: GetCharacterEpisodesUseCase

	// MARK: - Initialization

	init() {
		sut = GetCharacterEpisodesUseCase(repository: repositoryMock)
	}

	// MARK: - Execute

	@Test("Execute returns episodes with correct identifier and localFirst cache policy")
	func executeReturnsEpisodes() async throws {
		// Given
		let expected = EpisodeCharacterWithEpisodes.stub()
		repositoryMock.result = .success(expected)

		// When
		let value = try await sut.execute(characterIdentifier: 42)

		// Then
		#expect(value == expected)
		#expect(repositoryMock.getEpisodesCallCount == 1)
		#expect(repositoryMock.lastRequestedCharacterIdentifier == 42)
		#expect(repositoryMock.lastCachePolicy == .localFirst)
	}

	@Test("Execute propagates repository error")
	func executePropagatesRepositoryError() async throws {
		// Given
		repositoryMock.result = .failure(.loadFailed())

		// When / Then
		await #expect(throws: EpisodeError.loadFailed()) {
			_ = try await sut.execute(characterIdentifier: 1)
		}
	}
}

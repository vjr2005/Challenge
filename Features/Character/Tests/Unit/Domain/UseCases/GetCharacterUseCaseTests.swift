import ChallengeCore
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct GetCharacterUseCaseTests {
    // MARK: - Properties

    private let repositoryMock = CharacterRepositoryMock()
    private let sut: GetCharacterUseCase

    // MARK: - Initialization

    init() {
        sut = GetCharacterUseCase(repository: repositoryMock)
    }

    // MARK: - Execute

    @Test("Execute returns character with correct identifier and localFirst cache policy")
    func executeReturnsCharacter() async throws {
        // Given
        let expected = Character.stub()
        repositoryMock.result = .success(expected)

        // When
        let value = try await sut.execute(identifier: 42)

        // Then
        #expect(value == expected)
        #expect(repositoryMock.getCharacterCallCount == 1)
        #expect(repositoryMock.lastRequestedIdentifier == 42)
        #expect(repositoryMock.lastCharacterCachePolicy == .localFirst)
    }

    @Test("Execute propagates repository error")
    func executePropagatesRepositoryError() async throws {
        // Given
        repositoryMock.result = .failure(.loadFailed())

        // When / Then
        await #expect(throws: CharacterError.loadFailed()) {
            _ = try await sut.execute(identifier: 1)
        }
    }
}

import ChallengeCore
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct RefreshCharacterUseCaseTests {
    // MARK: - Properties

    private let repositoryMock = CharacterRepositoryMock()
    private let sut: RefreshCharacterUseCase

    // MARK: - Initialization

    init() {
        sut = RefreshCharacterUseCase(repository: repositoryMock)
    }

    // MARK: - Execute

    @Test("Execute returns character from repository")
    func executeReturnsCharacter() async throws {
        // Given
        let expected = Character.stub()
        repositoryMock.result = .success(expected)

        // When
        let value = try await sut.execute(identifier: 1)

        // Then
        #expect(value == expected)
    }

    @Test("Execute calls repository with correct identifier and remoteFirst cache policy")
    func executeCallsRepositoryWithCorrectIdentifierAndRemoteFirstCachePolicy() async throws {
        // Given
        repositoryMock.result = .success(.stub())

        // When
        _ = try await sut.execute(identifier: 42)

        // Then
        #expect(repositoryMock.getCharacterCallCount == 1)
        #expect(repositoryMock.lastRequestedIdentifier == 42)
        #expect(repositoryMock.lastCharacterCachePolicy == .remoteFirst)
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

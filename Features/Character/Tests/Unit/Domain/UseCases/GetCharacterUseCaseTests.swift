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

    // MARK: - Execute with CachePolicy

    @Test("Returns character from repository with specified cache policy")
    func returnsCharacterWithCachePolicy() async throws {
        // Given
        let expected = Character.stub()
        repositoryMock.result = .success(expected)

        // When
        let value = try await sut.execute(identifier: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(value == expected)
    }

    @Test("Calls repository with correct identifier and cache policy")
    func callsRepositoryWithCorrectIdAndCachePolicy() async throws {
        // Given
        repositoryMock.result = .success(.stub())

        // When
        _ = try await sut.execute(identifier: 42, cachePolicy: .remoteFirst)

        // Then
        #expect(repositoryMock.getCharacterCallCount == 1)
        #expect(repositoryMock.lastRequestedIdentifier == 42)
        #expect(repositoryMock.lastCharacterCachePolicy == .remoteFirst)
    }

    @Test("Propagates repository error")
    func propagatesRepositoryError() async throws {
        // Given
        repositoryMock.result = .failure(.loadFailed)

        // When / Then
        await #expect(throws: CharacterError.loadFailed) {
            _ = try await sut.execute(identifier: 1, cachePolicy: .localFirst)
        }
    }

    // MARK: - Default Extension

    @Test("Default execute uses localFirst cache policy")
    func defaultExecuteUsesLocalFirstCachePolicy() async throws {
        // Given
        repositoryMock.result = .success(.stub())

        // When
        _ = try await sut.execute(identifier: 1)

        // Then
        #expect(repositoryMock.lastCharacterCachePolicy == .localFirst)
    }
}

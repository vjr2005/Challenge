import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterErrorTests {
    // MARK: - Equatability

    @Test(arguments: [
        (CharacterError.loadFailed, CharacterError.loadFailed, true),
        (CharacterError.characterNotFound(id: 1), CharacterError.characterNotFound(id: 1), true),
        (CharacterError.characterNotFound(id: 1), CharacterError.characterNotFound(id: 2), false),
        (CharacterError.invalidPage(page: 1), CharacterError.invalidPage(page: 1), true),
        (CharacterError.invalidPage(page: 1), CharacterError.invalidPage(page: 2), false),
        (CharacterError.loadFailed, CharacterError.characterNotFound(id: 1), false),
        (CharacterError.loadFailed, CharacterError.invalidPage(page: 1), false),
        (CharacterError.characterNotFound(id: 1), CharacterError.invalidPage(page: 1), false)
    ])
    func equality(
        lhs: CharacterError,
        rhs: CharacterError,
        expectedEqual: Bool
    ) {
        // When
        let areEqual = lhs == rhs

        // Then
        #expect(areEqual == expectedEqual)
    }

    // MARK: - LocalizedError

    @Test("Load failed error description is localized")
    func loadFailedErrorDescriptionIsLocalized() {
        // Given
        let sut = CharacterError.loadFailed

        // When
        let description = sut.errorDescription

        // Then
        #expect(description != nil)
        #expect(description?.isEmpty == false)
    }

    @Test("Character not found error description contains id")
    func characterNotFoundErrorDescriptionContainsId() {
        // Given
        let sut = CharacterError.characterNotFound(id: 42)

        // When
        let description = sut.errorDescription

        // Then
        #expect(description != nil)
        #expect(description?.contains("42") == true)
    }

    @Test("Invalid page error description contains page number")
    func invalidPageErrorDescriptionContainsPage() {
        // Given
        let sut = CharacterError.invalidPage(page: 5)

        // When
        let description = sut.errorDescription

        // Then
        #expect(description != nil)
        #expect(description?.contains("5") == true)
    }

    // MARK: - Sendable

    @Test("Error is Sendable across contexts")
    func errorIsSendable() async {
        // Given
        let error = CharacterError.loadFailed

        // When
        let sentError = await sendToAnotherContext(error)

        // Then
        #expect(sentError == error)
    }
}

// MARK: - Helpers

private func sendToAnotherContext(_ error: CharacterError) async -> CharacterError {
    await Task { error }.value
}

import Foundation
import Testing

@testable import ChallengeCharacter

struct CharactersPageErrorTests {
    // MARK: - Equatability

    @Test(arguments: [
        (CharactersPageError.loadFailed, CharactersPageError.loadFailed, true),
        (CharactersPageError.invalidPage(page: 1), CharactersPageError.invalidPage(page: 1), true),
        (CharactersPageError.invalidPage(page: 1), CharactersPageError.invalidPage(page: 2), false),
        (CharactersPageError.loadFailed, CharactersPageError.invalidPage(page: 1), false)
    ])
    func equality(
        lhs: CharactersPageError,
        rhs: CharactersPageError,
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
        let sut = CharactersPageError.loadFailed

        // When
        let description = sut.errorDescription

        // Then
        #expect(description != nil)
        #expect(description?.isEmpty == false)
    }

    @Test("Invalid page error description contains page number")
    func invalidPageErrorDescriptionContainsPage() {
        // Given
        let sut = CharactersPageError.invalidPage(page: 5)

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
        let error = CharactersPageError.loadFailed

        // When
        let sentError = await sendToAnotherContext(error)

        // Then
        #expect(sentError == error)
    }
}

// MARK: - Helpers

private func sendToAnotherContext(_ error: CharactersPageError) async -> CharactersPageError {
    await Task { error }.value
}

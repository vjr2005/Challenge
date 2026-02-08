import Foundation
import Testing

@testable import ChallengeCharacter

struct CharactersPageErrorTests {
    // MARK: - Equatability

    @Test(arguments: [
        (CharactersPageError.loadFailed(), CharactersPageError.loadFailed(), true),
        (CharactersPageError.invalidPage(page: 1), CharactersPageError.invalidPage(page: 1), true),
        (CharactersPageError.invalidPage(page: 1), CharactersPageError.invalidPage(page: 2), false),
        (CharactersPageError.loadFailed(), CharactersPageError.invalidPage(page: 1), false)
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
        let sut = CharactersPageError.loadFailed()

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

    // MARK: - CustomDebugStringConvertible

    @Test("Load failed debugDescription returns the original error description")
    func loadFailedDebugDescriptionReturnsDescription() {
        // Given
        let sut = CharactersPageError.loadFailed(description: "dataCorrupted: test")

        // When
        let result = sut.debugDescription

        // Then
        #expect(result == "dataCorrupted: test")
    }

    @Test("Load failed debugDescription returns empty string when no description")
    func loadFailedDebugDescriptionReturnsEmptyByDefault() {
        // Given
        let sut = CharactersPageError.loadFailed()

        // When
        let result = sut.debugDescription

        // Then
        #expect(result == "")
    }

    @Test("Invalid page debugDescription contains page number")
    func invalidPageDebugDescriptionContainsPage() {
        // Given
        let sut = CharactersPageError.invalidPage(page: 5)

        // When
        let result = sut.debugDescription

        // Then
        #expect(result.contains("5"))
    }

    // MARK: - Equatable ignores description

    @Test("Two loadFailed with different descriptions are equal")
    func loadFailedWithDifferentDescriptionsAreEqual() {
        // Given
        let lhs = CharactersPageError.loadFailed(description: "error A")
        let rhs = CharactersPageError.loadFailed(description: "error B")

        // When
        let areEqual = lhs == rhs

        // Then
        #expect(areEqual)
    }

    // MARK: - Sendable

    @Test("Error is Sendable across contexts")
    func errorIsSendable() async {
        // Given
        let error = CharactersPageError.loadFailed()

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

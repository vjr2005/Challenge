import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterErrorTests {
    // MARK: - Equatability

    @Test(arguments: [
        (CharacterError.loadFailed(), CharacterError.loadFailed(), true),
        (CharacterError.notFound(identifier: 1), CharacterError.notFound(identifier: 1), true),
        (CharacterError.notFound(identifier: 1), CharacterError.notFound(identifier: 2), false),
        (CharacterError.loadFailed(), CharacterError.notFound(identifier: 1), false)
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
        let sut = CharacterError.loadFailed()

        // When
        let description = sut.errorDescription

        // Then
        #expect(description != nil)
        #expect(description?.isEmpty == false)
    }

    @Test("Not found error description contains id")
    func notFoundErrorDescriptionContainsId() {
        // Given
        let sut = CharacterError.notFound(identifier: 42)

        // When
        let description = sut.errorDescription

        // Then
        #expect(description != nil)
        #expect(description?.contains("42") == true)
    }

    // MARK: - CustomDebugStringConvertible

    @Test("Load failed debugDescription returns the original error description")
    func loadFailedDebugDescriptionReturnsDescription() {
        // Given
        let sut = CharacterError.loadFailed(description: "dataCorrupted: test")

        // When
        let result = sut.debugDescription

        // Then
        #expect(result == "dataCorrupted: test")
    }

    @Test("Load failed debugDescription returns empty string when no description")
    func loadFailedDebugDescriptionReturnsEmptyByDefault() {
        // Given
        let sut = CharacterError.loadFailed()

        // When
        let result = sut.debugDescription

        // Then
        #expect(result == "")
    }

    @Test("Not found debugDescription contains identifier")
    func notFoundDebugDescriptionContainsIdentifier() {
        // Given
        let sut = CharacterError.notFound(identifier: 42)

        // When
        let result = sut.debugDescription

        // Then
        #expect(result.contains("42"))
    }

    // MARK: - Equatable ignores description

    @Test("Two loadFailed with different descriptions are equal")
    func loadFailedWithDifferentDescriptionsAreEqual() {
        // Given
        let lhs = CharacterError.loadFailed(description: "error A")
        let rhs = CharacterError.loadFailed(description: "error B")

        // When
        let areEqual = lhs == rhs

        // Then
        #expect(areEqual)
    }

    // MARK: - Sendable

    @Test("Error is Sendable across contexts")
    func errorIsSendable() async {
        // Given
        let error = CharacterError.loadFailed()

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

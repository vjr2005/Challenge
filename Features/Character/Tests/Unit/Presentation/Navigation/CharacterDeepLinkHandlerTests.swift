import ChallengeCore
import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterDeepLinkHandlerTests {
    // MARK: - Properties

    private let sut = CharacterDeepLinkHandler()

    // MARK: - Scheme

    @Test("Scheme is challenge")
    func schemeIsChallenge() {
        #expect(sut.scheme == "challenge")
    }

    // MARK: - Host

    @Test("Host is character")
    func hostIsCharacter() {
        #expect(sut.host == "character")
    }

    // MARK: - Resolve

    @Test("Resolves character list deep link URL")
    func resolvesListURL() throws {
        // Given
        let url = try #require(URL(string: "challenge://character/list"))
        let expected = CharacterIncomingNavigation.list

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value as? CharacterIncomingNavigation == expected)
    }

    @Test("Resolves character detail deep link URL with id")
    func resolvesDetailURL() throws {
        // Given
        let url = try #require(URL(string: "challenge://character/detail/42"))
        let expected = CharacterIncomingNavigation.detail(identifier: 42)

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value as? CharacterIncomingNavigation == expected)
    }

    @Test("Returns nil for unknown path")
    func returnsNilForUnknownPath() throws {
        // Given
        let url = try #require(URL(string: "challenge://character/unknown"))

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value == nil)
    }

    @Test("Returns nil for detail path without id")
    func returnsNilForDetailWithoutId() throws {
        // Given
        let url = try #require(URL(string: "challenge://character/detail"))

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value == nil)
    }

    @Test("Returns nil for detail path with non-numeric id")
    func returnsNilForDetailWithInvalidId() throws {
        // Given
        let url = try #require(URL(string: "challenge://character/detail/abc"))

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value == nil)
    }
}

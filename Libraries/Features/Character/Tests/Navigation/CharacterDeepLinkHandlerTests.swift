import ChallengeCore
import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterDeepLinkHandlerTests {
    @Test
    func resolvesListURL() throws {
        // Given
        let sut = CharacterDeepLinkHandler()
        let url = try #require(URL(string: "challenge://character/list"))
        let expected = CharacterNavigation.list

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value as? CharacterNavigation == expected)
    }

    @Test
    func resolvesDetailURL() throws {
        // Given
        let sut = CharacterDeepLinkHandler()
        let url = try #require(URL(string: "challenge://character/detail?id=42"))
        let expected = CharacterNavigation.detail(identifier: 42)

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value as? CharacterNavigation == expected)
    }

    @Test
    func returnsNilForUnknownPath() throws {
        // Given
        let sut = CharacterDeepLinkHandler()
        let url = try #require(URL(string: "challenge://character/unknown"))

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value == nil)
    }

    @Test
    func returnsNilForDetailWithoutId() throws {
        // Given
        let sut = CharacterDeepLinkHandler()
        let url = try #require(URL(string: "challenge://character/detail"))

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value == nil)
    }

    @Test
    func returnsNilForDetailWithInvalidId() throws {
        // Given
        let sut = CharacterDeepLinkHandler()
        let url = try #require(URL(string: "challenge://character/detail?id=abc"))

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value == nil)
    }
}

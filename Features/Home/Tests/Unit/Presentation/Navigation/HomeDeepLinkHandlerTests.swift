import Foundation
import Testing

@testable import ChallengeHome

struct HomeDeepLinkHandlerTests {
    // MARK: - Properties

    @Test
    func schemeReturnsChallenge() {
        // Given
        let sut = HomeDeepLinkHandler()

        // When
        let result = sut.scheme

        // Then
        #expect(result == "challenge")
    }

    @Test
    func hostReturnsHome() {
        // Given
        let sut = HomeDeepLinkHandler()

        // When
        let result = sut.host

        // Then
        #expect(result == "home")
    }

    // MARK: - Resolve

    @Test
    func resolvesMainURL() throws {
        // Given
        let sut = HomeDeepLinkHandler()
        let url = try #require(URL(string: "challenge://home/main"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result is HomeIncomingNavigation)
    }

    @Test
    func resolvesRootURL() throws {
        // Given
        let sut = HomeDeepLinkHandler()
        let url = try #require(URL(string: "challenge://home/"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result is HomeIncomingNavigation)
    }

    @Test
    func returnsNilForUnknownPath() throws {
        // Given
        let sut = HomeDeepLinkHandler()
        let url = try #require(URL(string: "challenge://home/unknown"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result == nil)
    }
}

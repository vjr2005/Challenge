import Foundation
import Testing

@testable import ChallengeHome

struct HomeDeepLinkHandlerTests {
    // MARK: - Properties

    private let sut = HomeDeepLinkHandler()

    // MARK: - Scheme and Host

    @Test("Scheme returns 'challenge'")
    func schemeReturnsChallenge() {
        // When
        let result = sut.scheme

        // Then
        #expect(result == "challenge")
    }

    @Test("Host returns 'home'")
    func hostReturnsHome() {
        // When
        let result = sut.host

        // Then
        #expect(result == "home")
    }

    // MARK: - Resolve

    @Test("Resolves main path URL to home navigation")
    func resolvesMainURL() throws {
        // Given
        let url = try #require(URL(string: "challenge://home/main"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result is HomeIncomingNavigation)
    }

    @Test("Resolves root path URL to home navigation")
    func resolvesRootURL() throws {
        // Given
        let url = try #require(URL(string: "challenge://home/"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result is HomeIncomingNavigation)
    }

    @Test("Returns nil for unknown path")
    func returnsNilForUnknownPath() throws {
        // Given
        let url = try #require(URL(string: "challenge://home/unknown"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result == nil)
    }
}

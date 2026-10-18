import Foundation
import Testing

@testable import ChallengeHome

struct HomeDeepLinkHandlerTests {
    // MARK: - Properties

    private let sut = HomeDeepLinkHandler()

    // MARK: - Scheme

    @Test("Scheme is challenge")
    func schemeIsChallenge() {
        // When
        let scheme = sut.scheme

        // Then
        #expect(scheme == "challenge")
    }

    // MARK: - Host

    @Test("Host is home")
    func hostIsHome() {
        // When
        let host = sut.host

        // Then
        #expect(host == "home")
    }

    // MARK: - Resolve

    @Test("Resolves main path URL to home navigation")
    func resolvesMainURL() throws {
        // Given
        let url = try #require(URL(string: "challenge://home/main"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result as? HomeIncomingNavigation == .main)
    }

    @Test("Resolves root path URL to home navigation")
    func resolvesRootURL() throws {
        // Given
        let url = try #require(URL(string: "challenge://home/"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result as? HomeIncomingNavigation == .main)
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

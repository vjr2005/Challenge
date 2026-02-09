import ChallengeCore
import Foundation
import Testing

@testable import ChallengeEpisode

struct EpisodeDeepLinkHandlerTests {
    // MARK: - Properties

    private let sut = EpisodeDeepLinkHandler()

    // MARK: - Scheme

    @Test("Scheme is challenge")
    func schemeIsChallenge() {
        #expect(sut.scheme == "challenge")
    }

    // MARK: - Host

    @Test("Host is episode")
    func hostIsEpisode() {
        #expect(sut.host == "episode")
    }

    // MARK: - Resolve

    @Test("Resolve list path returns main navigation")
    func resolveListPathReturnsMainNavigation() throws {
        // Given
        let url = try #require(URL(string: "challenge://episode/list"))

        // When
        let result = sut.resolve(url)

        // Then
        let navigation = result as? EpisodeIncomingNavigation
        #expect(navigation == .main)
    }

    @Test("Resolve unknown path returns nil")
    func resolveUnknownPathReturnsNil() throws {
        // Given
        let url = try #require(URL(string: "challenge://episode/unknown"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result == nil)
    }
}

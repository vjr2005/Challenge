import Foundation
import Testing

@testable import ChallengeHome

struct HomeDeepLinkHandlerTests {
    @Test
    func resolvesMainURL() throws {
        // Given
        let sut = HomeDeepLinkHandler()
        let url = try #require(URL(string: "challenge://home/main"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result is HomeNavigation)
    }

    @Test
    func resolvesRootURL() throws {
        // Given
        let sut = HomeDeepLinkHandler()
        let url = try #require(URL(string: "challenge://home/"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result is HomeNavigation)
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

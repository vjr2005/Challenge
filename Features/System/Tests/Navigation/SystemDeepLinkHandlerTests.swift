import Foundation
import Testing

@testable import ChallengeSystem

struct SystemDeepLinkHandlerTests {
    @Test
    func schemeIsChallenge() {
        // Given
        let sut = SystemDeepLinkHandler()

        // Then
        #expect(sut.scheme == "challenge")
    }

    @Test
    func hostIsSystem() {
        // Given
        let sut = SystemDeepLinkHandler()

        // Then
        #expect(sut.host == "system")
    }

    @Test
    func resolveReturnsNilForAnyURL() throws {
        // Given
        let sut = SystemDeepLinkHandler()
        let url = try #require(URL(string: "challenge://system/anything"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result == nil)
    }
}

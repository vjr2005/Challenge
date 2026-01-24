import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterFeatureTests {
    // MARK: - Init

    @Test
    func initWithHTTPClientDoesNotCrash() {
        // Given
        let httpClientMock = HTTPClientMock()

        // When
        let sut = CharacterFeature(httpClient: httpClientMock)

        // Then - Feature initializes without crashing
        _ = sut
    }

    // MARK: - Feature Protocol

    @Test
    func registerDeepLinksRegistersCharacterHandler() throws {
        // Given
        let httpClientMock = HTTPClientMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        sut.registerDeepLinks()

        // Then - Deep link is registered (verify by resolving a known URL)
        let url = try #require(URL(string: "challenge://character/list"))
        let navigation = DeepLinkRegistry.shared.resolve(url)
        #expect(navigation != nil)
    }

    @Test
    func registerDeepLinksRegistersDetailPath() throws {
        // Given
        let httpClientMock = HTTPClientMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        sut.registerDeepLinks()

        // Then
        let url = try #require(URL(string: "challenge://character/detail?id=42"))
        let navigation = DeepLinkRegistry.shared.resolve(url)
        #expect(navigation != nil)
    }
}

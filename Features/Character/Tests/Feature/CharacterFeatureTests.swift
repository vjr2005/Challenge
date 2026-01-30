import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Testing

@testable import ChallengeCharacter

struct CharacterFeatureTests {
    // MARK: - Deep Link Handler

    @Test
    func deepLinkHandlerReturnsCharacterDeepLinkHandler() {
        // Given
        let httpClientMock = HTTPClientMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.deepLinkHandler

        // Then
        #expect(result is CharacterDeepLinkHandler)
    }

    // MARK: - View Factory

    @Test
    func viewForListNavigationReturnsCharacterListView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.view(for: .list, navigator: navigatorMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("CharacterListView"))
    }

    @Test
    func viewForDetailNavigationReturnsCharacterDetailView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.view(for: .detail(identifier: 42), navigator: navigatorMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("CharacterDetailView"))
    }
}

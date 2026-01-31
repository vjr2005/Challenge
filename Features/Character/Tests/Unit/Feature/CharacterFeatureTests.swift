import ChallengeCore
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

    // MARK: - Resolve

    @Test
    func resolveListNavigationReturnsCharacterListView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.resolve(.list, navigator: navigatorMock)

        // Then
        let viewName = String(describing: result)
        #expect(viewName.contains("CharacterListView"))
    }

    @Test
    func resolveDetailNavigationReturnsCharacterDetailView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.resolve(.detail(identifier: 42), navigator: navigatorMock)

        // Then
        let viewName = String(describing: result)
        #expect(viewName.contains("CharacterDetailView"))
    }

    @Test
    func tryResolveReturnsViewForCharacterNavigation() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.tryResolve(CharacterIncomingNavigation.list, navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    @Test
    func tryResolveReturnsNilForOtherNavigation() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.tryResolve(TestIncomingNavigation.other, navigator: navigatorMock)

        // Then
        #expect(result == nil)
    }
}

// MARK: - Test Helpers

private enum TestIncomingNavigation: IncomingNavigation {
    case other
}

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

    // MARK: - Main View

    @Test
    func makeMainViewReturnsCharacterListView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.makeMainView(navigator: navigatorMock)

        // Then
        let viewName = String(describing: result)
        #expect(viewName.contains("CharacterListView"))
    }

    // MARK: - Resolve

    @Test
    func resolveReturnsViewForListNavigation() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.resolve(CharacterIncomingNavigation.list, navigator: navigatorMock)

        // Then
        #expect(result != nil)
        let viewName = String(describing: result)
        #expect(viewName.contains("CharacterListView"))
    }

    @Test
    func resolveReturnsViewForDetailNavigation() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.resolve(CharacterIncomingNavigation.detail(identifier: 42), navigator: navigatorMock)

        // Then
        #expect(result != nil)
        let viewName = String(describing: result)
        #expect(viewName.contains("CharacterDetailView"))
    }

    @Test
    func resolveReturnsNilForOtherNavigation() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.resolve(TestNavigation.other, navigator: navigatorMock)

        // Then
        #expect(result == nil)
    }
}

// MARK: - Test Helpers

private enum TestNavigation: Navigation {
    case other
}

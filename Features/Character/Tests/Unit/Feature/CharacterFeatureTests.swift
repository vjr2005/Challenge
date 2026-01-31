import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Testing

@testable import ChallengeCharacter

struct CharacterFeatureTests {
    // MARK: - Properties

    private let httpClientMock = HTTPClientMock()
    private let sut: CharacterFeature

    // MARK: - Initialization

    init() {
        sut = CharacterFeature(httpClient: httpClientMock)
    }

    // MARK: - Deep Link Handler

    @Test
    func deepLinkHandlerReturnsCharacterDeepLinkHandler() {
        // When
        let result = sut.deepLinkHandler

        // Then
        #expect(result is CharacterDeepLinkHandler)
    }

    // MARK: - Main View

    @Test
    func makeMainViewReturnsCharacterListView() {
        // Given
        let navigatorMock = NavigatorMock()

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
        let navigatorMock = NavigatorMock()

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
        let navigatorMock = NavigatorMock()

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
        let navigatorMock = NavigatorMock()

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

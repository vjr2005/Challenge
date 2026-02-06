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
        sut = CharacterFeature(httpClient: httpClientMock, tracker: TrackerMock())
    }

    // MARK: - Deep Link Handler

    @Test("Deep link handler returns CharacterDeepLinkHandler")
    func deepLinkHandlerReturnsCharacterDeepLinkHandler() {
        // When
        let result = sut.deepLinkHandler

        // Then
        #expect(result is CharacterDeepLinkHandler)
    }

    // MARK: - Main View

    @Test("Main view returns CharacterListView")
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

    @Test("Resolve returns view for list navigation")
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

    @Test("Resolve returns view for detail navigation")
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

    @Test("Resolve returns view for advanced search navigation")
    func resolveReturnsViewForAdvancedSearchNavigation() {
        // Given
        let navigatorMock = NavigatorMock()

        // When
        let result = sut.resolve(CharacterIncomingNavigation.advancedSearch, navigator: navigatorMock)

        // Then
        #expect(result != nil)
        let viewName = String(describing: result)
        #expect(viewName.contains("AdvancedSearchView"))
    }

    @Test("Resolve returns nil for non-character navigation")
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

private enum TestNavigation: NavigationContract {
    case other
}

import ChallengeCore
import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct HomeFeatureTests {
    // MARK: - Properties

    private let sut = HomeFeature()

    // MARK: - Deep Link Handler

    @Test
    func deepLinkHandlerReturnsHomeDeepLinkHandler() {
        // When
        let result = sut.deepLinkHandler

        // Then
        #expect(result is HomeDeepLinkHandler)
    }

    // MARK: - Main View

    @Test
    func makeMainViewReturnsHomeView() {
        // Given
        let navigatorMock = NavigatorMock()

        // When
        let result = sut.makeMainView(navigator: navigatorMock)

        // Then
        let viewName = String(describing: result)
        #expect(viewName.contains("HomeView"))
    }

    // MARK: - Resolve

    @Test
    func resolveReturnsViewForHomeNavigation() {
        // Given
        let navigatorMock = NavigatorMock()

        // When
        let result = sut.resolve(HomeIncomingNavigation.main, navigator: navigatorMock)

        // Then
        #expect(result != nil)
        let viewName = String(describing: result)
        #expect(viewName.contains("HomeView"))
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

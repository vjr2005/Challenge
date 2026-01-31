import ChallengeCore
import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct HomeFeatureTests {
    // MARK: - Deep Link Handler

    @Test
    func deepLinkHandlerReturnsHomeDeepLinkHandler() {
        // Given
        let sut = HomeFeature()

        // When
        let result = sut.deepLinkHandler

        // Then
        #expect(result is HomeDeepLinkHandler)
    }

    // MARK: - Factory

    @Test
    func makeHomeViewReturnsHomeView() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = HomeFeature()

        // When
        let result = sut.makeHomeView(navigator: navigatorMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("HomeView"))
    }

    // MARK: - Resolve

    @Test
    func resolveMainNavigationReturnsHomeView() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = HomeFeature()

        // When
        let result = sut.resolve(.main, navigator: navigatorMock)

        // Then
        let viewName = String(describing: result)
        #expect(viewName.contains("HomeView"))
    }

    @Test
    func tryResolveReturnsViewForHomeNavigation() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = HomeFeature()

        // When
        let result = sut.tryResolve(HomeIncomingNavigation.main, navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    @Test
    func tryResolveReturnsNilForOtherNavigation() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = HomeFeature()

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

import ChallengeCore
import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct HomeFeatureTests {
    // MARK: - Properties

    private let sut = HomeFeature(tracker: TrackerMock())

    // MARK: - Deep Link Handler

    @Test("Deep link handler returns HomeDeepLinkHandler")
    func deepLinkHandlerReturnsHomeDeepLinkHandler() {
        // When
        let result = sut.deepLinkHandler

        // Then
        #expect(result is HomeDeepLinkHandler)
    }

    // MARK: - Main View

    @Test("Main view returns HomeView")
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

    @Test("Resolve returns view for home navigation")
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

    @Test("Resolve returns nil for non-home navigation")
    func resolveReturnsNilForOtherNavigation() {
        // Given
        let navigatorMock = NavigatorMock()

        // When
        let result = sut.resolve(TestNavigation.other, navigator: navigatorMock)

        // Then
        #expect(result == nil)
    }

    @Test("Resolve returns view for about navigation")
    func resolveReturnsViewForAboutNavigation() {
        // Given
        let navigatorMock = NavigatorMock()

        // When
        let result = sut.resolve(HomeIncomingNavigation.about, navigator: navigatorMock)

        // Then
        #expect(result != nil)
        let viewName = String(describing: result)
        #expect(viewName.contains("AboutView"))
    }
}

// MARK: - Test Helpers

private enum TestNavigation: NavigationContract {
    case other
}

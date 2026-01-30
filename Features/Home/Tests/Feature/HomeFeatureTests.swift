import ChallengeCore
import ChallengeCoreMocks
import SwiftUI
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

    // MARK: - Navigation Destination

    @Test
    func applyNavigationDestinationReturnsView() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = HomeFeature()
        let baseView = EmptyView()

        // When
        let result = sut.applyNavigationDestination(to: baseView, navigator: navigatorMock)

        // Then
        let typeName = String(describing: type(of: result))
        #expect(typeName == "AnyView")
    }

    // MARK: - View Factory

    @Test
    func viewForMainNavigationReturnsHomeView() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = HomeFeature()

        // When
        let result = sut.view(for: .main, navigator: navigatorMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("HomeView"))
    }
}

import ChallengeCore
import ChallengeCoreMocks
import SwiftUI
import Testing

@testable import ChallengeHome

struct HomeFeatureTests {
    // MARK: - Init

    @Test
    func initDoesNotCrash() {
        // When
        let sut = HomeFeature()

        // Then
        _ = sut
    }

    // MARK: - Factory

    @Test
    func makeHomeViewReturnsConfiguredInstance() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = HomeFeature()

        // When
        let view = sut.makeHomeView(navigator: navigatorMock)

        // Then
        _ = view
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
        _ = result
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

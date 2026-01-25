import ChallengeCore
import ChallengeCoreMocks
import SwiftUI
import Testing

@testable import ChallengeHome

@Suite(.timeLimit(.minutes(1)))
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
        let routerMock = RouterMock()
        let sut = HomeFeature()

        // When
        let view = sut.makeHomeView(router: routerMock)

        // Then
        _ = view
    }

    // MARK: - Deep Links

    @Test
    func registerDeepLinksRegistersHomeHandler() throws {
        // Given
        let sut = HomeFeature()

        // When
        sut.registerDeepLinks()

        // Then
        let url = try #require(URL(string: "challenge://home/main"))
        let navigation = DeepLinkRegistry.shared.resolve(url)
        #expect(navigation != nil)
    }

    // MARK: - Navigation Destination

    @Test
    func applyNavigationDestinationReturnsView() {
        // Given
        let routerMock = RouterMock()
        let sut = HomeFeature()
        let baseView = EmptyView()

        // When
        let result = sut.applyNavigationDestination(to: baseView, router: routerMock)

        // Then
        _ = result
    }

    // MARK: - View Factory

    @Test
    func viewForMainNavigationReturnsHomeView() {
        // Given
        let routerMock = RouterMock()
        let sut = HomeFeature()

        // When
        let result = sut.view(for: .main, router: routerMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("HomeView"))
    }
}

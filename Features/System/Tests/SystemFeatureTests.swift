import ChallengeCore
import ChallengeCoreMocks
import SwiftUI
import Testing

@testable import ChallengeSystem

struct SystemFeatureTests {
    @Test
    func applyNavigationDestinationReturnsView() {
        // Given
        let sut = SystemFeature()
        let navigatorMock = NavigatorMock()
        let baseView = EmptyView()

        // When
        let result = sut.applyNavigationDestination(to: baseView, navigator: navigatorMock)

        // Then
        let typeName = String(describing: type(of: result))
        #expect(typeName == "AnyView")
    }

    // MARK: - View Factory

    @Test
    func viewForUnknownNavigationReturnsNotFoundView() {
        // Given
        let sut = SystemFeature()
        let navigatorMock = NavigatorMock()

        // When
        let result = sut.view(for: .notFound, navigator: navigatorMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("NotFoundView"))
    }
}

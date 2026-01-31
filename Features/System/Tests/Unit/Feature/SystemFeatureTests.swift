import ChallengeCore
import ChallengeCoreMocks
import Testing

@testable import ChallengeSystem

struct SystemFeatureTests {
    // MARK: - Resolve

    @Test
    func resolveNotFoundNavigationReturnsNotFoundView() {
        // Given
        let sut = SystemFeature()
        let navigatorMock = NavigatorMock()

        // When
        let result = sut.resolve(.notFound, navigator: navigatorMock)

        // Then
        let viewName = String(describing: result)
        #expect(viewName.contains("NotFoundView"))
    }

    @Test
    func tryResolveReturnsViewForUnknownNavigation() {
        // Given
        let sut = SystemFeature()
        let navigatorMock = NavigatorMock()

        // When
        let result = sut.tryResolve(UnknownNavigation.notFound, navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    @Test
    func tryResolveReturnsNilForOtherNavigation() {
        // Given
        let sut = SystemFeature()
        let navigatorMock = NavigatorMock()

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

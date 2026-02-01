import ChallengeCore
import ChallengeCoreMocks
import Testing

@testable import ChallengeSystem

struct SystemFeatureTests {
    // MARK: - Properties

    private let sut = SystemFeature()

    // MARK: - Deep Link Handler

    @Test("Deep link handler returns nil for system feature")
    func deepLinkHandlerReturnsNil() {
        // When
        let result = sut.deepLinkHandler

        // Then
        #expect(result == nil)
    }

    // MARK: - Main View

    @Test("Main view returns not found view")
    func makeMainViewReturnsNotFoundView() {
        // Given
        let navigatorMock = NavigatorMock()

        // When
        let result = sut.makeMainView(navigator: navigatorMock)

        // Then
        let viewName = String(describing: result)
        #expect(viewName.contains("NotFoundView"))
    }

    // MARK: - Resolve

    @Test("Resolve returns view for unknown navigation")
    func resolveReturnsViewForUnknownNavigation() {
        // Given
        let navigatorMock = NavigatorMock()

        // When
        let result = sut.resolve(UnknownNavigation.notFound, navigator: navigatorMock)

        // Then
        #expect(result != nil)
        let viewName = String(describing: result)
        #expect(viewName.contains("NotFoundView"))
    }

    @Test("Resolve returns nil for non-unknown navigation types")
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

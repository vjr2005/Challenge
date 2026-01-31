import ChallengeCore
import ChallengeCoreMocks
import Testing

@testable import ChallengeSystem

struct SystemFeatureTests {
    // MARK: - Properties

    private let sut = SystemFeature()

    // MARK: - Deep Link Handler

    @Test
    func deepLinkHandlerReturnsNil() {
        // When
        let result = sut.deepLinkHandler

        // Then
        #expect(result == nil)
    }

    // MARK: - Main View

    @Test
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

    @Test
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

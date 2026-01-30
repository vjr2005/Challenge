import ChallengeCoreMocks
import Testing

@testable import ChallengeSystem

struct SystemFeatureTests {
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

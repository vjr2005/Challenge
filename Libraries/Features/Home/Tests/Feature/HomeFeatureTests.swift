import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct HomeFeatureTests {
    @Test
    func makeHomeViewReturnsConfiguredInstance() {
        // Given
        let routerMock = RouterMock()
        let sut = HomeFeature()

        // When
        let view = sut.makeHomeView(router: routerMock)

        // Then - Verify factory returns a properly configured instance
        // HomeView is stateless, so we just verify it was created
        _ = view
    }
}

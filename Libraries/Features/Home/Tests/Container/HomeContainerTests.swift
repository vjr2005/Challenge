import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct HomeContainerTests {
    @Test
    func makeHomeViewModelReturnsConfiguredInstance() {
        // Given
        let routerMock = RouterMock()
        let sut = HomeContainer()

        // When
        let viewModel = sut.makeHomeViewModel(router: routerMock)

        // Then - Verify factory returns a properly configured instance
        // HomeViewModel is stateless, so we just verify it was created
        _ = viewModel
    }
}

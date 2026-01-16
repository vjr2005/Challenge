import ChallengeCharacter
import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct HomeViewModelTests {
    @Test
    func didTapOnCharacterButtonNavigatesToCharacterDetail() {
        // Given
        let router = RouterMock()
        let sut = HomeViewModel(router: router)

        // When
        sut.didTapOnCharacterButton()

        // Then
        let destination = router.navigatedDestinations.first as? CharacterNavigation
        #expect(destination == .detail(identifier: 1))
    }

    @Test
    func didTapOnCharacterButtonCallsRouterOnce() {
        // Given
        let router = RouterMock()
        let sut = HomeViewModel(router: router)

        // When
        sut.didTapOnCharacterButton()

        // Then
        #expect(router.navigatedDestinations.count == 1)
    }
}

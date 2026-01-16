import ChallengeCharacter
import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct HomeViewModelTests {
    @Test
    func didTapOnCharacterButtonNavigatesToCharacterList() {
        // Given
        let router = RouterMock()
        let sut = HomeViewModel(router: router)

        // When
        sut.didTapOnCharacterButton()

        // Then
        let destination = router.navigatedDestinations.first as? CharacterNavigation
        #expect(destination == .list)
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

import ChallengeCharacter
import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct HomeViewModelTests {
    @Test
    func didTapOnCharacterButtonNavigatesToCharacterList() {
        // Given
        let routerMock = RouterMock()
        let sut = HomeViewModel(router: routerMock)

        // When
        sut.didTapOnCharacterButton()

        // Then
        let destination = routerMock.navigatedDestinations.first as? CharacterNavigation
        #expect(destination == .list)
    }

    @Test
    func didTapOnCharacterButtonCallsRouterOnce() {
        // Given
        let routerMock = RouterMock()
        let sut = HomeViewModel(router: routerMock)

        // When
        sut.didTapOnCharacterButton()

        // Then
        #expect(routerMock.navigatedDestinations.count == 1)
    }
}

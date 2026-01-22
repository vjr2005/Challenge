import ChallengeCoreMocks
import Testing

@testable import ChallengeCharacter

struct CharacterListNavigatorTests {
    @Test
    func navigateToDetailUsesCorrectNavigation() {
        // Given
        let routerMock = RouterMock()
        let sut = CharacterListNavigator(router: routerMock)
        let expected = CharacterNavigation.detail(identifier: 42)

        // When
        sut.navigateToDetail(id: 42)

        // Then
        let destination = routerMock.navigatedDestinations.first as? CharacterNavigation
        #expect(destination == expected)
    }

    @Test
    func navigateToDetailCallsRouterOnce() {
        // Given
        let routerMock = RouterMock()
        let sut = CharacterListNavigator(router: routerMock)

        // When
        sut.navigateToDetail(id: 1)

        // Then
        #expect(routerMock.navigatedDestinations.count == 1)
    }
}

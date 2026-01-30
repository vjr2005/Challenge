import ChallengeCoreMocks
import Testing

@testable import ChallengeCharacter

struct CharacterListNavigatorTests {
    @Test
    func navigateToDetailUsesCorrectNavigation() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = CharacterListNavigator(navigator: navigatorMock)
        let expected = CharacterIncomingNavigation.detail(identifier: 42)

        // When
        sut.navigateToDetail(id: 42)

        // Then
        let destination = navigatorMock.navigatedDestinations.first as? CharacterIncomingNavigation
        #expect(destination == expected)
    }

    @Test
    func navigateToDetailCallsNavigatorOnce() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = CharacterListNavigator(navigator: navigatorMock)

        // When
        sut.navigateToDetail(id: 1)

        // Then
        #expect(navigatorMock.navigatedDestinations.count == 1)
    }
}

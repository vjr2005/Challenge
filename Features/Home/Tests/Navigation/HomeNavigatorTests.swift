import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeHome

struct HomeNavigatorTests {
    @Test
    func navigateToCharactersUsesCorrectNavigation() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = HomeNavigator(navigator: navigatorMock)
        let expected = HomeOutgoingNavigation.characters

        // When
        sut.navigateToCharacters()

        // Then
        let destination = navigatorMock.navigatedDestinations.first as? HomeOutgoingNavigation
        #expect(destination == expected)
    }

    @Test
    func navigateToCharactersCallsNavigatorOnce() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = HomeNavigator(navigator: navigatorMock)

        // When
        sut.navigateToCharacters()

        // Then
        #expect(navigatorMock.navigatedDestinations.count == 1)
    }
}

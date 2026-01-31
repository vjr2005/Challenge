import ChallengeCoreMocks
import Testing

@testable import ChallengeCharacter

struct CharacterDetailNavigatorTests {
    // MARK: - Properties

    private let navigatorMock = NavigatorMock()
    private let sut: CharacterDetailNavigator

    // MARK: - Initialization

    init() {
        sut = CharacterDetailNavigator(navigator: navigatorMock)
    }

    // MARK: - Tests

    @Test
    func goBackCallsNavigator() {
        // When
        sut.goBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }
}

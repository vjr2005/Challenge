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

    @Test("Go back delegates to navigator")
    func goBackCallsNavigator() {
        // When
        sut.goBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }
}

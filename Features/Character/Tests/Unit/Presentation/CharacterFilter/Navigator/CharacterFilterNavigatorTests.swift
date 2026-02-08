import ChallengeCoreMocks
import Testing

@testable import ChallengeCharacter

struct CharacterFilterNavigatorTests {
    // MARK: - Properties

    private let navigatorMock = NavigatorMock()
    private let sut: CharacterFilterNavigator

    // MARK: - Initialization

    init() {
        sut = CharacterFilterNavigator(navigator: navigatorMock)
    }

    // MARK: - Tests

    @Test("Dismiss calls navigator dismiss")
    func dismissCallsNavigatorDismiss() {
        // When
        sut.dismiss()

        // Then
        #expect(navigatorMock.dismissCallCount == 1)
    }
}

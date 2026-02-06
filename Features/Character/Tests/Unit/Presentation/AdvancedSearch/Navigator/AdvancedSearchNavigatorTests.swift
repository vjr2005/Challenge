import ChallengeCoreMocks
import Testing

@testable import ChallengeCharacter

struct AdvancedSearchNavigatorTests {
    // MARK: - Properties

    private let navigatorMock = NavigatorMock()
    private let sut: AdvancedSearchNavigator

    // MARK: - Initialization

    init() {
        sut = AdvancedSearchNavigator(navigator: navigatorMock)
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

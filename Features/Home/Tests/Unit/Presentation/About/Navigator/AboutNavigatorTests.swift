import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct AboutNavigatorTests {
    // MARK: - Properties

    private let navigatorMock = NavigatorMock()
    private let sut: AboutNavigator

    // MARK: - Initialization

    init() {
        sut = AboutNavigator(navigator: navigatorMock)
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

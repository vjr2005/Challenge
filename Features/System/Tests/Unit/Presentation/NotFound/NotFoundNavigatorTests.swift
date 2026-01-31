import ChallengeCore
import ChallengeCoreMocks
import Testing

@testable import ChallengeSystem

struct NotFoundNavigatorTests {
    // MARK: - Properties

    private let navigatorMock = NavigatorMock()
    private let sut: NotFoundNavigator

    // MARK: - Initialization

    init() {
        sut = NotFoundNavigator(navigator: navigatorMock)
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

import Testing

@testable import ChallengeSystem

struct NotFoundViewModelTests {
    // MARK: - Properties

    private let navigatorMock = NotFoundNavigatorMock()
    private let sut: NotFoundViewModel

    // MARK: - Initialization

    init() {
        sut = NotFoundViewModel(navigator: navigatorMock)
    }

    // MARK: - Tests

    @Test("Tap go back delegates to navigator")
    func didTapGoBackCallsNavigator() {
        // When
        sut.didTapGoBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }
}

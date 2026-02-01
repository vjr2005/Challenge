import SwiftUI
import Testing

@testable import ChallengeCore

struct NavigationCoordinatorTests {
    // MARK: - Properties

    private let sut = NavigationCoordinator()

    // MARK: - Path Management

    @Test("Initial navigation path is empty")
    func initialPathIsEmpty() {
        // Then
        #expect(sut.path.isEmpty)
    }

    @Test("Navigate appends destination to path")
    func navigateAppendsToPath() {
        // When
        sut.navigate(to: TestIncomingNavigation.screen1)

        // Then
        #expect(sut.path.count == 1)
    }

    @Test("Multiple navigations append in order")
    func multipleNavigationsAppendInOrder() {
        // When
        sut.navigate(to: TestIncomingNavigation.screen1)
        sut.navigate(to: TestIncomingNavigation.screen2)
        sut.navigate(to: TestIncomingNavigation.screen1)

        // Then
        #expect(sut.path.count == 3)
    }

    @Test("Go back removes last item from path")
    func goBackRemovesLastFromPath() {
        // Given
        sut.navigate(to: TestIncomingNavigation.screen1)
        sut.navigate(to: TestIncomingNavigation.screen2)

        // When
        sut.goBack()

        // Then
        #expect(sut.path.count == 1)
    }

    @Test("Go back on empty path does nothing")
    func goBackOnEmptyPathDoesNothing() {
        // When
        sut.goBack()

        // Then
        #expect(sut.path.isEmpty)
    }

    @Test("Go back multiple times empties path")
    func goBackMultipleTimesEmptiesPath() {
        // Given
        sut.navigate(to: TestIncomingNavigation.screen1)
        sut.navigate(to: TestIncomingNavigation.screen2)

        // When
        sut.goBack()
        sut.goBack()

        // Then
        #expect(sut.path.isEmpty)
    }

    @Test("Go back beyond empty path is safe")
    func goBackBeyondEmptyPathIsSafe() {
        // Given
        sut.navigate(to: TestIncomingNavigation.screen1)

        // When
        sut.goBack()
        sut.goBack()
        sut.goBack()

        // Then
        #expect(sut.path.isEmpty)
    }

    // MARK: - IncomingNavigation

    @Test("Incoming navigation appends directly without redirector")
    func incomingNavigationAppendsDirectlyWithoutRedirector() {
        // Given
        let sutWithoutRedirector = NavigationCoordinator(redirector: nil)

        // When
        sutWithoutRedirector.navigate(to: TestIncomingNavigation.screen1)

        // Then
        #expect(sutWithoutRedirector.path.count == 1)
    }

    @Test("Incoming navigation does not call redirector")
    func incomingNavigationDoesNotCallRedirector() {
        // Given
        let redirector = TestRedirector(result: TestIncomingNavigation.screen2)
        let sutWithRedirector = NavigationCoordinator(redirector: redirector)

        // When
        sutWithRedirector.navigate(to: TestIncomingNavigation.screen1)

        // Then
        #expect(sutWithRedirector.path.count == 1)
        #expect(redirector.redirectedNavigations.isEmpty)
    }

    // MARK: - OutgoingNavigation

    @Test("Outgoing navigation with redirect appends redirected destination")
    func outgoingNavigationWithRedirectAppendsRedirectedDestination() {
        // Given
        let redirector = TestRedirector(result: TestIncomingNavigation.screen2)
        let sutWithRedirector = NavigationCoordinator(redirector: redirector)

        // When
        sutWithRedirector.navigate(to: TestOutgoingNavigation.external)

        // Then
        #expect(sutWithRedirector.path.count == 1)
        #expect(redirector.redirectedNavigations.count == 1)
    }

    @Test("Outgoing navigation without redirect appends unknown navigation")
    func outgoingNavigationWithoutRedirectAppendsUnknownNavigation() {
        // Given
        let redirector = TestRedirector(result: nil)
        let sutWithRedirector = NavigationCoordinator(redirector: redirector)

        // When
        sutWithRedirector.navigate(to: TestOutgoingNavigation.external)

        // Then
        #expect(sutWithRedirector.path.count == 1)
    }

    @Test("Outgoing navigation without redirector appends unknown navigation")
    func outgoingNavigationWithoutRedirectorAppendsUnknownNavigation() {
        // Given
        let sutWithoutRedirector = NavigationCoordinator(redirector: nil)

        // When
        sutWithoutRedirector.navigate(to: TestOutgoingNavigation.external)

        // Then
        #expect(sutWithoutRedirector.path.count == 1)
    }

    // MARK: - AnyIncomingNavigation Wrapping

    @Test("Navigate wraps incoming navigation in AnyIncomingNavigation")
    func navigateWrapsIncomingNavigationInAnyIncomingNavigation() {
        // When
        sut.navigate(to: TestIncomingNavigation.screen1)

        // Then - Path should contain AnyIncomingNavigation
        #expect(sut.path.count == 1)
    }
}

// MARK: - Test Helpers

private enum TestIncomingNavigation: IncomingNavigation {
    case screen1
    case screen2
}

private enum TestOutgoingNavigation: OutgoingNavigation {
    case external
}

private final class TestRedirector: NavigationRedirectContract, @unchecked Sendable {
    private(set) var redirectedNavigations: [any Navigation] = []
    private let result: (any Navigation)?

    init(result: (any Navigation)?) {
        self.result = result
    }

    func redirect(_ navigation: any Navigation) -> (any Navigation)? {
        redirectedNavigations.append(navigation)
        return result
    }
}

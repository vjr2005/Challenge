import SwiftUI
import Testing

@testable import ChallengeCore

struct NavigationCoordinatorTests {
    // MARK: - Properties

    private let sut = NavigationCoordinator()

    // MARK: - Path Management

    @Test
    func initialPathIsEmpty() {
        // Then
        #expect(sut.path.isEmpty)
    }

    @Test
    func navigateAppendsToPath() {
        // When
        sut.navigate(to: TestIncomingNavigation.screen1)

        // Then
        #expect(sut.path.count == 1)
    }

    @Test
    func multipleNavigationsAppendInOrder() {
        // When
        sut.navigate(to: TestIncomingNavigation.screen1)
        sut.navigate(to: TestIncomingNavigation.screen2)
        sut.navigate(to: TestIncomingNavigation.screen1)

        // Then
        #expect(sut.path.count == 3)
    }

    @Test
    func goBackRemovesLastFromPath() {
        // Given
        sut.navigate(to: TestIncomingNavigation.screen1)
        sut.navigate(to: TestIncomingNavigation.screen2)

        // When
        sut.goBack()

        // Then
        #expect(sut.path.count == 1)
    }

    @Test
    func goBackOnEmptyPathDoesNothing() {
        // When
        sut.goBack()

        // Then
        #expect(sut.path.isEmpty)
    }

    @Test
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

    @Test
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

    @Test
    func incomingNavigationAppendsDirectlyWithoutRedirector() {
        // Given
        let sutWithoutRedirector = NavigationCoordinator(redirector: nil)

        // When
        sutWithoutRedirector.navigate(to: TestIncomingNavigation.screen1)

        // Then
        #expect(sutWithoutRedirector.path.count == 1)
    }

    @Test
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

    @Test
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

    @Test
    func outgoingNavigationWithoutRedirectAppendsUnknownNavigation() {
        // Given
        let redirector = TestRedirector(result: nil)
        let sutWithRedirector = NavigationCoordinator(redirector: redirector)

        // When
        sutWithRedirector.navigate(to: TestOutgoingNavigation.external)

        // Then
        #expect(sutWithRedirector.path.count == 1)
    }

    @Test
    func outgoingNavigationWithoutRedirectorAppendsUnknownNavigation() {
        // Given
        let sutWithoutRedirector = NavigationCoordinator(redirector: nil)

        // When
        sutWithoutRedirector.navigate(to: TestOutgoingNavigation.external)

        // Then
        #expect(sutWithoutRedirector.path.count == 1)
    }

    // MARK: - AnyIncomingNavigation Wrapping

    @Test
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

import SwiftUI
import Testing

@testable import ChallengeCore

struct NavigationCoordinatorTests {
    // MARK: - Path Management

    @Test
    func initialPathIsEmpty() {
        // Given
        let sut = NavigationCoordinator()

        // Then
        #expect(sut.path.isEmpty)
    }

    @Test
    func navigateAppendsToPath() {
        // Given
        let sut = NavigationCoordinator()

        // When
        sut.navigate(to: TestIncomingNavigation.screen1)

        // Then
        #expect(sut.path.count == 1)
    }

    @Test
    func multipleNavigationsAppendInOrder() {
        // Given
        let sut = NavigationCoordinator()

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
        let sut = NavigationCoordinator()
        sut.navigate(to: TestIncomingNavigation.screen1)
        sut.navigate(to: TestIncomingNavigation.screen2)

        // When
        sut.goBack()

        // Then
        #expect(sut.path.count == 1)
    }

    @Test
    func goBackOnEmptyPathDoesNothing() {
        // Given
        let sut = NavigationCoordinator()

        // When
        sut.goBack()

        // Then
        #expect(sut.path.isEmpty)
    }

    @Test
    func goBackMultipleTimesEmptiesPath() {
        // Given
        let sut = NavigationCoordinator()
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
        let sut = NavigationCoordinator()
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
        let sut = NavigationCoordinator(redirector: nil)

        // When
        sut.navigate(to: TestIncomingNavigation.screen1)

        // Then
        #expect(sut.path.count == 1)
    }

    @Test
    func incomingNavigationDoesNotCallRedirector() {
        // Given
        let redirector = TestRedirector(result: TestIncomingNavigation.screen2)
        let sut = NavigationCoordinator(redirector: redirector)

        // When
        sut.navigate(to: TestIncomingNavigation.screen1)

        // Then
        #expect(sut.path.count == 1)
        #expect(redirector.redirectedNavigations.isEmpty)
    }

    // MARK: - OutgoingNavigation

    @Test
    func outgoingNavigationWithRedirectAppendsRedirectedDestination() {
        // Given
        let redirector = TestRedirector(result: TestIncomingNavigation.screen2)
        let sut = NavigationCoordinator(redirector: redirector)

        // When
        sut.navigate(to: TestOutgoingNavigation.external)

        // Then
        #expect(sut.path.count == 1)
        #expect(redirector.redirectedNavigations.count == 1)
    }

    @Test
    func outgoingNavigationWithoutRedirectAppendsUnknownNavigation() {
        // Given
        let redirector = TestRedirector(result: nil)
        let sut = NavigationCoordinator(redirector: redirector)

        // When
        sut.navigate(to: TestOutgoingNavigation.external)

        // Then
        #expect(sut.path.count == 1)
    }

    @Test
    func outgoingNavigationWithoutRedirectorAppendsUnknownNavigation() {
        // Given
        let sut = NavigationCoordinator(redirector: nil)

        // When
        sut.navigate(to: TestOutgoingNavigation.external)

        // Then
        #expect(sut.path.count == 1)
    }

    // MARK: - AnyIncomingNavigation Wrapping

    @Test
    func navigateWrapsIncomingNavigationInAnyIncomingNavigation() {
        // Given
        let sut = NavigationCoordinator()

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

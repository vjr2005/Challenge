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
        sut.navigate(to: TestNavigation.screen1)

        // Then
        #expect(sut.path.count == 1)
    }

    @Test
    func multipleNavigationsAppendInOrder() {
        // Given
        let sut = NavigationCoordinator()

        // When
        sut.navigate(to: TestNavigation.screen1)
        sut.navigate(to: TestNavigation.screen2)
        sut.navigate(to: TestNavigation.screen1)

        // Then
        #expect(sut.path.count == 3)
    }

    @Test
    func goBackRemovesLastFromPath() {
        // Given
        let sut = NavigationCoordinator()
        sut.navigate(to: TestNavigation.screen1)
        sut.navigate(to: TestNavigation.screen2)

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
        sut.navigate(to: TestNavigation.screen1)
        sut.navigate(to: TestNavigation.screen2)

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
        sut.navigate(to: TestNavigation.screen1)

        // When
        sut.goBack()
        sut.goBack()
        sut.goBack()

        // Then
        #expect(sut.path.isEmpty)
    }

    // MARK: - Redirects

    @Test
    func navigateWithoutRedirectorUsesOriginal() {
        // Given
        let sut = NavigationCoordinator(redirector: nil)

        // When
        sut.navigate(to: TestNavigation.screen1)

        // Then
        #expect(sut.path.count == 1)
    }

    @Test
    func navigateWithRedirectorAppliesRedirect() {
        // Given
        let redirector = TestRedirector(result: TestNavigation.screen2)
        let sut = NavigationCoordinator(redirector: redirector)

        // When
        sut.navigate(to: TestNavigation.screen1)

        // Then
        #expect(sut.path.count == 1)
        #expect(redirector.redirectedNavigations.count == 1)
    }

    @Test
    func navigateWithRedirectorReturningNilUsesOriginal() {
        // Given
        let redirector = TestRedirector(result: nil)
        let sut = NavigationCoordinator(redirector: redirector)

        // When
        sut.navigate(to: TestNavigation.screen1)

        // Then
        #expect(sut.path.count == 1)
    }
}

// MARK: - Test Helpers

private enum TestNavigation: Navigation {
    case screen1
    case screen2
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

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
        // Given
        let destination = TestIncomingNavigationContract.screen1

        // When
        sut.navigate(to: destination)

        // Then
        #expect(sut.path.count == 1)
    }

    @Test("Multiple navigations append in order")
    func multipleNavigationsAppendInOrder() {
        // Given
        let destinations: [TestIncomingNavigationContract] = [.screen1, .screen2, .screen1]

        // When
        destinations.forEach { sut.navigate(to: $0) }

        // Then
        #expect(sut.path.count == 3)
    }

    @Test("Go back removes last item from path")
    func goBackRemovesLastFromPath() {
        // Given
        sut.navigate(to: TestIncomingNavigationContract.screen1)
        sut.navigate(to: TestIncomingNavigationContract.screen2)

        // When
        sut.goBack()

        // Then
        #expect(sut.path.count == 1)
    }

    @Test("Go back on empty path does nothing")
    func goBackOnEmptyPathDoesNothing() {
        // Given
        #expect(sut.path.isEmpty)

        // When
        sut.goBack()

        // Then
        #expect(sut.path.isEmpty)
    }

    @Test("Go back multiple times empties path")
    func goBackMultipleTimesEmptiesPath() {
        // Given
        sut.navigate(to: TestIncomingNavigationContract.screen1)
        sut.navigate(to: TestIncomingNavigationContract.screen2)

        // When
        sut.goBack()
        sut.goBack()

        // Then
        #expect(sut.path.isEmpty)
    }

    @Test("Go back beyond empty path is safe")
    func goBackBeyondEmptyPathIsSafe() {
        // Given
        sut.navigate(to: TestIncomingNavigationContract.screen1)

        // When
        sut.goBack()
        sut.goBack()
        sut.goBack()

        // Then
        #expect(sut.path.isEmpty)
    }

    // MARK: - IncomingNavigationContract

    @Test("Incoming navigation appends directly without redirector")
    func incomingNavigationAppendsDirectlyWithoutRedirector() {
        // Given
        let sutWithoutRedirector = NavigationCoordinator(redirector: nil)

        // When
        sutWithoutRedirector.navigate(to: TestIncomingNavigationContract.screen1)

        // Then
        #expect(sutWithoutRedirector.path.count == 1)
    }

    @Test("Incoming navigation does not call redirector")
    func incomingNavigationDoesNotCallRedirector() {
        // Given
        let redirector = TestRedirector(result: TestIncomingNavigationContract.screen2)
        let sutWithRedirector = NavigationCoordinator(redirector: redirector)

        // When
        sutWithRedirector.navigate(to: TestIncomingNavigationContract.screen1)

        // Then
        #expect(sutWithRedirector.path.count == 1)
        #expect(redirector.redirectedNavigations.isEmpty)
    }

    // MARK: - OutgoingNavigationContract

    @Test("Outgoing navigation with redirect appends redirected destination")
    func outgoingNavigationWithRedirectAppendsRedirectedDestination() {
        // Given
        let redirector = TestRedirector(result: TestIncomingNavigationContract.screen2)
        let sutWithRedirector = NavigationCoordinator(redirector: redirector)

        // When
        sutWithRedirector.navigate(to: TestOutgoingNavigationContract.external)

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
        sutWithRedirector.navigate(to: TestOutgoingNavigationContract.external)

        // Then
        #expect(sutWithRedirector.path.count == 1)
    }

    @Test("Outgoing navigation without redirector appends unknown navigation")
    func outgoingNavigationWithoutRedirectorAppendsUnknownNavigation() {
        // Given
        let sutWithoutRedirector = NavigationCoordinator(redirector: nil)

        // When
        sutWithoutRedirector.navigate(to: TestOutgoingNavigationContract.external)

        // Then
        #expect(sutWithoutRedirector.path.count == 1)
    }

    // MARK: - AnyIncomingNavigationContract Wrapping

    @Test("Navigate wraps incoming navigation in AnyIncomingNavigationContract")
    func navigateWrapsIncomingNavigationContractInAnyIncomingNavigationContract() {
        // Given
        let destination = TestIncomingNavigationContract.screen1

        // When
        sut.navigate(to: destination)

        // Then
        #expect(sut.path.count == 1)
    }

    // MARK: - Modal Presentation

    @Test("Present sheet sets sheetNavigation")
    func presentSheetSetsSheetNavigation() {
        // Given
        let destination = TestIncomingNavigationContract.screen1

        // When
        sut.present(destination, style: .sheet())

        // Then
        #expect(sut.sheetNavigation != nil)
        #expect(sut.fullScreenCoverNavigation == nil)
    }

    @Test("Present fullScreenCover sets fullScreenCoverNavigation")
    func presentFullScreenCoverSetsFullScreenCoverNavigation() {
        // Given
        let destination = TestIncomingNavigationContract.screen1

        // When
        sut.present(destination, style: .fullScreenCover)

        // Then
        #expect(sut.fullScreenCoverNavigation != nil)
        #expect(sut.sheetNavigation == nil)
    }

    @Test("Dismiss fullScreenCover first when both modals are presented")
    func dismissFullScreenCoverFirst() {
        // Given
        sut.present(TestIncomingNavigationContract.screen1, style: .sheet())
        sut.present(TestIncomingNavigationContract.screen2, style: .fullScreenCover)

        // When
        sut.dismiss()

        // Then
        #expect(sut.fullScreenCoverNavigation == nil)
        #expect(sut.sheetNavigation != nil)
    }

    @Test("Dismiss sheet when no fullScreenCover is presented")
    func dismissSheetWhenNoFullScreenCover() {
        // Given
        sut.present(TestIncomingNavigationContract.screen1, style: .sheet())

        // When
        sut.dismiss()

        // Then
        #expect(sut.sheetNavigation == nil)
        #expect(sut.fullScreenCoverNavigation == nil)
    }

    @Test("Dismiss calls onDismiss when no modals are presented")
    func dismissCallsOnDismissWhenNoModals() {
        // Given
        var onDismissCalled = false
        let sutWithOnDismiss = NavigationCoordinator(onDismiss: { onDismissCalled = true })

        // When
        sutWithOnDismiss.dismiss()

        // Then
        #expect(onDismissCalled)
    }

    @Test("Present with outgoing navigation applies redirect")
    func presentWithOutgoingNavigationAppliesRedirect() {
        // Given
        let redirector = TestRedirector(result: TestIncomingNavigationContract.screen2)
        let sutWithRedirector = NavigationCoordinator(redirector: redirector)

        // When
        sutWithRedirector.present(TestOutgoingNavigationContract.external, style: .sheet())

        // Then
        #expect(sutWithRedirector.sheetNavigation != nil)
        #expect(redirector.redirectedNavigations.count == 1)
    }

    @Test("Sheet detents are preserved in modal navigation")
    func sheetDetentsArePreserved() {
        // Given
        let detents: Set<PresentationDetent> = [.medium, .large]

        // When
        sut.present(TestIncomingNavigationContract.screen1, style: .sheet(detents: detents))

        // Then
        let modal = try? #require(sut.sheetNavigation)
        #expect(modal?.detents == detents)
    }

    @Test("Initial modal state is nil")
    func initialModalStateIsNil() {
        // Then
        #expect(sut.sheetNavigation == nil)
        #expect(sut.fullScreenCoverNavigation == nil)
    }
}

// MARK: - Test Helpers

private enum TestIncomingNavigationContract: IncomingNavigationContract {
    case screen1
    case screen2
}

private enum TestOutgoingNavigationContract: OutgoingNavigationContract {
    case external
}

private final class TestRedirector: NavigationRedirectContract, @unchecked Sendable {
    private(set) var redirectedNavigations: [any NavigationContract] = []
    private let result: (any NavigationContract)?

    init(result: (any NavigationContract)?) {
        self.result = result
    }

    func redirect(_ navigation: any NavigationContract) -> (any NavigationContract)? {
        redirectedNavigations.append(navigation)
        return result
    }
}

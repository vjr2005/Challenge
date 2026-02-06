import ChallengeCore
import Foundation

/// Mock implementation of `NavigatorContract` for testing navigation.
public final class NavigatorMock: NavigatorContract {
    /// The destinations navigated to.
    public private(set) var navigatedDestinations: [any NavigationContract] = []

    /// The modals presented with their styles.
    public private(set) var presentedModals: [(destination: any NavigationContract, style: ModalPresentationStyle)] = []

    /// The number of times `dismiss()` was called.
    public private(set) var dismissCallCount = 0

    /// The number of times `goBack()` was called.
    public private(set) var goBackCallCount = 0

    /// Creates a new navigator mock.
    public init() {}

    /// Records a navigation to the given destination.
    public func navigate(to destination: any NavigationContract) {
        navigatedDestinations.append(destination)
    }

    /// Records a modal presentation.
    public func present(_ destination: any NavigationContract, style: ModalPresentationStyle) {
        presentedModals.append((destination: destination, style: style))
    }

    /// Increments the dismiss call count.
    public func dismiss() {
        dismissCallCount += 1
    }

    /// Increments the go-back call count.
    public func goBack() {
        goBackCallCount += 1
    }
}

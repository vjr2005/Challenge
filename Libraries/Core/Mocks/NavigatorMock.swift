import ChallengeCore
import Foundation

/// Mock implementation of `NavigatorContract` for testing navigation.
public final class NavigatorMock: NavigatorContract {
    /// The destinations navigated to.
    public private(set) var navigatedDestinations: [any NavigationContract] = []

    /// The number of times `goBack()` was called.
    public private(set) var goBackCallCount = 0

    /// Creates a new navigator mock.
    public init() {}

    /// Records a navigation to the given destination.
    public func navigate(to destination: any NavigationContract) {
        navigatedDestinations.append(destination)
    }

    /// Increments the go-back call count.
    public func goBack() {
        goBackCallCount += 1
    }
}

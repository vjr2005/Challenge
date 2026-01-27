import ChallengeCore
import Foundation

/// Mock implementation of `RouterContract` for testing navigation.
public final class RouterMock: RouterContract {
    /// The destinations navigated to via `navigate(to: Navigation)`.
    public private(set) var navigatedDestinations: [any Navigation] = []
    /// The URLs navigated to via `navigate(to: URL?)`.
    public private(set) var navigatedURLs: [URL] = []
    /// The number of times `goBack()` was called.
    public private(set) var goBackCallCount = 0

    /// Creates a new router mock.
    public init() {}

    /// Records a navigation to the given destination.
    public func navigate(to destination: any Navigation) {
        navigatedDestinations.append(destination)
    }

    /// Records a navigation to the given URL.
    public func navigate(to url: URL?) {
        guard let url else {
            return
        }
        navigatedURLs.append(url)
    }

    /// Increments the go-back call count.
    public func goBack() {
        goBackCallCount += 1
    }
}

import ChallengeCore
import Foundation

public final class RouterMock: RouterContract {
    public private(set) var navigatedDestinations: [any Navigation] = []
    public private(set) var navigatedURLs: [URL] = []
    public private(set) var goBackCallCount = 0

    public init() {}

    public func navigate(to destination: any Navigation) {
        navigatedDestinations.append(destination)
    }

    public func navigate(to url: URL?) {
        guard let url else {
            return
        }
        navigatedURLs.append(url)
    }

    public func goBack() {
        goBackCallCount += 1
    }
}

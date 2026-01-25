import ChallengeCore
import Foundation

struct HomeDeepLinkHandler: DeepLinkHandler {
    let scheme = "challenge"
    let host = "home"

    /// Registers this handler with the shared DeepLinkRegistry.
    @MainActor
    static func register() {
        DeepLinkRegistry.shared.register(Self())
    }

    func resolve(_ url: URL) -> (any Navigation)? {
        switch url.path {
        case "/main", "/":
            return HomeNavigation.main

        default:
            return nil
        }
    }
}

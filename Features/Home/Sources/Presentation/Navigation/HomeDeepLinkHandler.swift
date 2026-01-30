import ChallengeCore
import Foundation

struct HomeDeepLinkHandler: DeepLinkHandler {
    let scheme = "challenge"
    let host = "home"

    func resolve(_ url: URL) -> (any Navigation)? {
        switch url.path {
        case "/main", "/":
            return HomeIncomingNavigation.main

        default:
            return nil
        }
    }
}

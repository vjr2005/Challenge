import ChallengeCore
import Foundation

struct HomeDeepLinkHandler: DeepLinkHandlerContract {
    let scheme = "challenge"
    let host = "home"

    func resolve(_ url: URL) -> (any NavigationContract)? {
        switch url.path {
        case "/main", "/":
            return HomeIncomingNavigation.main

        default:
            return nil
        }
    }
}

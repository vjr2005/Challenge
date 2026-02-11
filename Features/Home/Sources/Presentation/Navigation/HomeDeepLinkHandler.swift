import ChallengeCore
import Foundation

struct HomeDeepLinkHandler: DeepLinkHandlerContract {
    let scheme = "challenge"
    let host = "home"

    func resolve(_ url: URL) -> (any NavigationContract)? {
        let pathComponents = url.pathComponents

        switch pathComponents.count {
        case 1:
            return HomeIncomingNavigation.main

        case 2 where pathComponents[1] == "main":
            return HomeIncomingNavigation.main

        default:
            return nil
        }
    }
}

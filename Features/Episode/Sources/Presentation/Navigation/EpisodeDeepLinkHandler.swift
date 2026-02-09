import ChallengeCore
import Foundation

struct EpisodeDeepLinkHandler: DeepLinkHandlerContract {
    let scheme = "challenge"
    let host = "episode"

    func resolve(_ url: URL) -> (any NavigationContract)? {
        switch url.path {
        case "/list":
            EpisodeIncomingNavigation.main

        default:
            nil
        }
    }
}

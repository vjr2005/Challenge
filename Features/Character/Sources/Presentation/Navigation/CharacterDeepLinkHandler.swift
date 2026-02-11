import ChallengeCore
import Foundation

struct CharacterDeepLinkHandler: DeepLinkHandlerContract {
    let scheme = "challenge"
    let host = "character"

    func resolve(_ url: URL) -> (any NavigationContract)? {
        let pathComponents = url.pathComponents

        switch pathComponents.count {
        case 2 where pathComponents[1] == "list":
            return CharacterIncomingNavigation.list

        case 3 where pathComponents[1] == "detail":
            guard let id = Int(pathComponents[2]) else {
                return nil
            }
            return CharacterIncomingNavigation.detail(identifier: id)

        default:
            return nil
        }
    }
}

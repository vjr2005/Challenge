import ChallengeCore
import Foundation

struct CharacterDeepLinkHandler: DeepLinkHandler {
    let scheme = "challenge"
    let host = "character"

    func resolve(_ url: URL) -> (any Navigation)? {
        switch url.path {
        case "/list":
            return CharacterIncomingNavigation.list

        case "/detail":
            guard let id = url.queryParameter("id").flatMap(Int.init) else {
                return nil
            }
            return CharacterIncomingNavigation.detail(identifier: id)

        default:
            return nil
        }
    }
}

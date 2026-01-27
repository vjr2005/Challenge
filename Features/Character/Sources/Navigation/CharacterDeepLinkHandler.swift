import ChallengeCore
import Foundation

struct CharacterDeepLinkHandler: DeepLinkHandler {
    let scheme = "challenge"
    let host = "character"

    @MainActor
    static func register() {
        DeepLinkRegistry.shared.register(Self())
    }

    func resolve(_ url: URL) -> (any Navigation)? {
        switch url.path {
        case "/list":
            return CharacterNavigation.list

        case "/detail":
            guard let id = url.queryParameter("id").flatMap(Int.init) else {
                return nil
            }
            return CharacterNavigation.detail(identifier: id)

        default:
            return nil
        }
    }
}

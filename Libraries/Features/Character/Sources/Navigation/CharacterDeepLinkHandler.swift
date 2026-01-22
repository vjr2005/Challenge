import ChallengeCore
import Foundation

public struct CharacterDeepLinkHandler: DeepLinkHandler {
    public let scheme = "challenge"
    public let host = "character"

    public init() {}

    /// Registers this handler with the shared DeepLinkRegistry.
    @MainActor
    public static func register() {
        DeepLinkRegistry.shared.register(Self())
    }

    public func resolve(_ url: URL) -> (any Navigation)? {
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

import ChallengeCore
import Foundation

struct SystemDeepLinkHandler: DeepLinkHandler {
    let scheme = "challenge"
    let host = "system"

    func resolve(_ url: URL) -> (any Navigation)? {
        // System feature does not handle any deep links directly
        nil
    }
}

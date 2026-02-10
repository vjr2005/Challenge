import ChallengeCore
import Foundation

struct EpisodeDeepLinkHandler: DeepLinkHandlerContract {
	let scheme = "challenge"
	let host = "episode"

	func resolve(_ url: URL) -> (any NavigationContract)? {
		let pathComponents = url.pathComponents
		guard pathComponents.count == 3,
		      pathComponents[1] == "character",
		      let identifier = Int(pathComponents[2]) else {
			return nil
		}
		return EpisodeIncomingNavigation.characterEpisodes(characterIdentifier: identifier)
	}
}

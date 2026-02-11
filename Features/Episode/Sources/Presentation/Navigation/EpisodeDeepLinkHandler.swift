import ChallengeCore
import Foundation

struct EpisodeDeepLinkHandler: DeepLinkHandlerContract {
	let scheme = "challenge"
	let host = "episode"

	func resolve(_ url: URL) -> (any NavigationContract)? {
		let pathComponents = url.pathComponents

		switch pathComponents.count {
		case 3 where pathComponents[1] == "character":
			guard let identifier = Int(pathComponents[2]) else {
				return nil
			}
			return EpisodeIncomingNavigation.characterEpisodes(characterIdentifier: identifier)

		default:
			return nil
		}
	}
}

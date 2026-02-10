import Foundation

struct EpisodeCharacterWithEpisodes: Equatable {
	let id: Int
	let name: String
	let imageURL: URL?
	let episodes: [Episode]
}

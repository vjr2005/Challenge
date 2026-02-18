import Foundation

nonisolated struct EpisodeCharacterWithEpisodesDTO: Decodable, Equatable {
	let id: String
	let name: String
	let image: String
	let episodes: [EpisodeDTO]

	enum CodingKeys: String, CodingKey {
		case id, name, image
		case episodes = "episode"
	}
}

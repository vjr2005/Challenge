import Foundation

nonisolated struct EpisodeDTO: Decodable, Equatable {
	let id: String
	let name: String
	let airDate: String
	let episode: String
	let characters: [EpisodeCharacterDTO]

	enum CodingKeys: String, CodingKey {
		case id, name, episode, characters
		case airDate = "air_date"
	}
}

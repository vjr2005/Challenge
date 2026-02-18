import Foundation

nonisolated struct EpisodeCharacterDTO: Decodable, Equatable {
	let id: String
	let name: String
	let image: String
}

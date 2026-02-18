import Foundation

nonisolated struct Episode: Equatable {
	let id: Int
	let name: String
	let airDate: String
	let episode: String
	let characters: [EpisodeCharacter]
}

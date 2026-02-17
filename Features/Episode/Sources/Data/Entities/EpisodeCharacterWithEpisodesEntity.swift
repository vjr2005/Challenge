import Foundation
import SwiftData

@Model
nonisolated final class EpisodeCharacterWithEpisodesEntity {
	@Attribute(.unique) var identifier: Int
	var name: String
	var image: String

	@Relationship(deleteRule: .cascade, inverse: \EpisodeEntity.characterWithEpisodes)
	var episodes: [EpisodeEntity]

	init(
		identifier: Int,
		name: String,
		image: String,
		episodes: [EpisodeEntity]
	) {
		self.identifier = identifier
		self.name = name
		self.image = image
		self.episodes = episodes
	}
}

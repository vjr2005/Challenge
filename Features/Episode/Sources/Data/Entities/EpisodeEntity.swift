import Foundation
import SwiftData

@Model
nonisolated final class EpisodeEntity {
	@Attribute(.unique) var identifier: Int
	var name: String
	var airDate: String
	var episode: String

	@Relationship(deleteRule: .cascade, inverse: \EpisodeCharacterEntity.episode)
	var characters: [EpisodeCharacterEntity]

	var characterWithEpisodes: EpisodeCharacterWithEpisodesEntity?

	init(
		identifier: Int,
		name: String,
		airDate: String,
		episode: String,
		characters: [EpisodeCharacterEntity]
	) {
		self.identifier = identifier
		self.name = name
		self.airDate = airDate
		self.episode = episode
		self.characters = characters
	}
}

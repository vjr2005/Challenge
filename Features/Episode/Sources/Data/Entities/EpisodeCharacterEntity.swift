import Foundation
import SwiftData

@Model
nonisolated final class EpisodeCharacterEntity {
	var identifier: Int
	var name: String
	var image: String
	var episode: EpisodeEntity?

	init(
		identifier: Int,
		name: String,
		image: String
	) {
		self.identifier = identifier
		self.name = name
		self.image = image
	}
}

import ChallengeCore
import Foundation

nonisolated struct EpisodeCharacterMapper: MapperContract {
	func map(_ input: EpisodeCharacterDTO) -> EpisodeCharacter {
		EpisodeCharacter(
			id: Int(input.id) ?? 0,
			name: input.name,
			imageURL: URL(string: input.image)
		)
	}
}

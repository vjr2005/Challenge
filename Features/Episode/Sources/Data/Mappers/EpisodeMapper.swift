import ChallengeCore
import Foundation

struct EpisodeMapper: MapperContract {
	private let characterMapper = EpisodeCharacterMapper()

	func map(_ input: EpisodeDTO) -> Episode {
		Episode(
			id: Int(input.id) ?? 0,
			name: input.name,
			airDate: input.airDate,
			episode: input.episode,
			characters: input.characters.map { characterMapper.map($0) }
		)
	}
}

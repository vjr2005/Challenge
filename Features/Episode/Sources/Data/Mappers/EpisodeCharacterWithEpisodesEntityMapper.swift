import ChallengeCore
import Foundation

struct EpisodeCharacterWithEpisodesEntityMapper: MapperContract {
	nonisolated func map(_ input: EpisodeCharacterWithEpisodesDTO) -> EpisodeCharacterWithEpisodesEntity {
		EpisodeCharacterWithEpisodesEntity(
			identifier: Int(input.id) ?? 0,
			name: input.name,
			image: input.image,
			episodes: input.episodes.map { episodeDTO in
				EpisodeEntity(
					identifier: Int(episodeDTO.id) ?? 0,
					name: episodeDTO.name,
					airDate: episodeDTO.airDate,
					episode: episodeDTO.episode,
					characters: episodeDTO.characters.map { characterDTO in
						EpisodeCharacterEntity(
							identifier: Int(characterDTO.id) ?? 0,
							name: characterDTO.name,
							image: characterDTO.image
						)
					}
				)
			}
		)
	}
}

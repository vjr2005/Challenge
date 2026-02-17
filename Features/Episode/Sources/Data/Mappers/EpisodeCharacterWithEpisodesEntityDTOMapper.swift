import ChallengeCore
import Foundation

struct EpisodeCharacterWithEpisodesEntityDTOMapper: MapperContract {
	nonisolated func map(_ input: EpisodeCharacterWithEpisodesEntity) -> EpisodeCharacterWithEpisodesDTO {
		EpisodeCharacterWithEpisodesDTO(
			id: String(input.identifier),
			name: input.name,
			image: input.image,
			episodes: input.episodes
				.sorted { $0.identifier < $1.identifier }
				.map { episodeEntity in
					EpisodeDTO(
						id: String(episodeEntity.identifier),
						name: episodeEntity.name,
						airDate: episodeEntity.airDate,
						episode: episodeEntity.episode,
						characters: episodeEntity.characters
							.sorted { $0.identifier < $1.identifier }
							.map { characterEntity in
								EpisodeCharacterDTO(
									id: String(characterEntity.identifier),
									name: characterEntity.name,
									image: characterEntity.image
								)
							}
					)
				}
		)
	}
}

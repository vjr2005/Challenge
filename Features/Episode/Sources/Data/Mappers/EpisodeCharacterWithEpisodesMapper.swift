import ChallengeCore
import Foundation

struct EpisodeCharacterWithEpisodesMapper: MapperContract {
	private let episodeMapper = EpisodeMapper()

	func map(_ input: EpisodeCharacterWithEpisodesDTO) -> EpisodeCharacterWithEpisodes {
		EpisodeCharacterWithEpisodes(
			id: Int(input.id) ?? 0,
			name: input.name,
			imageURL: URL(string: input.image),
			episodes: input.episodes.map { episodeMapper.map($0) }
		)
	}
}

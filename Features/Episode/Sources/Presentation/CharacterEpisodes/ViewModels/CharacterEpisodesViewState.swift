import Foundation

enum CharacterEpisodesViewState: Equatable {
	case idle
	case loading
	case loaded(EpisodeCharacterWithEpisodes)
	case error(EpisodeError)
}

import Foundation

enum CharacterEpisodesViewState {
	case idle
	case loading
	case loaded(EpisodeCharacterWithEpisodes)
	case error(EpisodeError)
}

import Foundation

@testable import ChallengeEpisode

extension EpisodeCharacterWithEpisodes {
	static func stub(
		id: Int = 1,
		name: String = "Rick Sanchez",
		imageURL: URL? = URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
		episodes: [Episode] = [.stub(), .stub(id: 2, name: "Lawnmower Dog", airDate: "December 9, 2013", episode: "S01E02", characters: [.stub()])]
	) -> EpisodeCharacterWithEpisodes {
		EpisodeCharacterWithEpisodes(
			id: id,
			name: name,
			imageURL: imageURL,
			episodes: episodes
		)
	}
}

@testable import ChallengeEpisode

nonisolated extension EpisodeCharacterWithEpisodesDTO {
	static func stub(
		id: String = "1",
		name: String = "Rick Sanchez",
		image: String = "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
		episodes: [EpisodeDTO] = [
			.stub(),
			.stub(
				id: "2",
				name: "Lawnmower Dog",
				airDate: "December 9, 2013",
				episode: "S01E02",
				characters: [.stub()]
			)
		]
	) -> EpisodeCharacterWithEpisodesDTO {
		EpisodeCharacterWithEpisodesDTO(
			id: id,
			name: name,
			image: image,
			episodes: episodes
		)
	}
}

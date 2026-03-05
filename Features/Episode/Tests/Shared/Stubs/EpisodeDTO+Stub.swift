@testable import ChallengeEpisode

nonisolated extension EpisodeDTO {
	static func stub(
		id: String = "1",
		name: String = "Pilot",
		airDate: String = "December 2, 2013",
		episode: String = "S01E01",
		characters: [EpisodeCharacterDTO] = [
			.stub(),
			.stub(id: "2", name: "Morty Smith", image: "https://rickandmortyapi.com/api/character/avatar/2.jpeg")
		]
	) -> EpisodeDTO {
		EpisodeDTO(
			id: id,
			name: name,
			airDate: airDate,
			episode: episode,
			characters: characters
		)
	}
}

import Foundation

@testable import ChallengeEpisode

extension Episode {
	static func stub(
		id: Int = 1,
		name: String = "Pilot",
		airDate: String = "December 2, 2013",
		episode: String = "S01E01",
		characters: [EpisodeCharacter] = [
			.stub(),
			.stub(id: 2, name: "Morty Smith", imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg"))
		]
	) -> Episode {
		Episode(
			id: id,
			name: name,
			airDate: airDate,
			episode: episode,
			characters: characters
		)
	}
}

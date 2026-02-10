import Foundation

@testable import ChallengeEpisode

extension EpisodeCharacter {
	static func stub(
		id: Int = 1,
		name: String = "Rick Sanchez",
		imageURL: URL? = URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
	) -> EpisodeCharacter {
		EpisodeCharacter(
			id: id,
			name: name,
			imageURL: imageURL
		)
	}
}

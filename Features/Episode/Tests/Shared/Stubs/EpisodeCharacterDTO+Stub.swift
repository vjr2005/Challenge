@testable import ChallengeEpisode

nonisolated extension EpisodeCharacterDTO {
	static func stub(
		id: String = "1",
		name: String = "Rick Sanchez",
		image: String = "https://rickandmortyapi.com/api/character/avatar/1.jpeg"
	) -> EpisodeCharacterDTO {
		EpisodeCharacterDTO(
			id: id,
			name: name,
			image: image
		)
	}
}

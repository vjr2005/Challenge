import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct EpisodeCharacterWithEpisodesEntityMapperTests {
	// MARK: - Properties

	private let sut = EpisodeCharacterWithEpisodesEntityMapper()

	// MARK: - Character Mapping

	@Test("Maps character identifier from string to integer")
	func mapsCharacterIdentifier() throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.identifier == 1)
	}

	@Test("Maps character name from DTO to entity")
	func mapsCharacterName() throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.name == "Rick Sanchez")
	}

	@Test("Maps character image from DTO to entity")
	func mapsCharacterImage() throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.image == "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
	}

	@Test("Maps non-numeric character id to zero")
	func mapsNonNumericCharacterIdToZero() {
		// Given
		let dto = EpisodeCharacterWithEpisodesDTO(
			id: "abc",
			name: "Test",
			image: "https://example.com/test.jpeg",
			episodes: []
		)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.identifier == 0)
	}

	// MARK: - Episode Mapping

	@Test("Maps episodes count from DTO to entity")
	func mapsEpisodesCount() throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.episodes.count == 2)
	}

	@Test("Maps episode properties from DTO to entity")
	func mapsEpisodeProperties() throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")

		// When
		let result = sut.map(dto)
		let firstEpisode = result.episodes.first { $0.identifier == 1 }

		// Then
		let episode = try #require(firstEpisode)
		#expect(episode.identifier == 1)
		#expect(episode.name == "Pilot")
		#expect(episode.airDate == "December 2, 2013")
		#expect(episode.episode == "S01E01")
	}

	@Test("Maps non-numeric episode id to zero")
	func mapsNonNumericEpisodeIdToZero() {
		// Given
		let dto = EpisodeCharacterWithEpisodesDTO(
			id: "1",
			name: "Rick",
			image: "https://example.com/rick.jpeg",
			episodes: [
				EpisodeDTO(
					id: "abc",
					name: "Invalid Episode",
					airDate: "December 2, 2013",
					episode: "S01E01",
					characters: []
				)
			]
		)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.episodes[0].identifier == 0)
	}

	// MARK: - Nested Character Mapping

	@Test("Maps nested characters within episodes")
	func mapsNestedCharacters() throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")

		// When
		let result = sut.map(dto)
		let firstEpisode = result.episodes.first { $0.identifier == 1 }

		// Then
		let episode = try #require(firstEpisode)
		#expect(episode.characters.count == 2)

		let rick = episode.characters.first { $0.identifier == 1 }
		#expect(rick?.name == "Rick Sanchez")
		#expect(rick?.image == "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
	}

	@Test("Maps non-numeric nested character id to zero")
	func mapsNonNumericNestedCharacterIdToZero() {
		// Given
		let dto = EpisodeCharacterWithEpisodesDTO(
			id: "1",
			name: "Rick",
			image: "https://example.com/rick.jpeg",
			episodes: [
				EpisodeDTO(
					id: "1",
					name: "Pilot",
					airDate: "December 2, 2013",
					episode: "S01E01",
					characters: [
						EpisodeCharacterDTO(
							id: "xyz",
							name: "Unknown",
							image: "https://example.com/unknown.jpeg"
						)
					]
				)
			]
		)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.episodes[0].characters[0].identifier == 0)
	}
}

// MARK: - Private

private extension EpisodeCharacterWithEpisodesEntityMapperTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}
}

import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct EpisodeCharacterWithEpisodesMapperTests {
	// MARK: - Properties

	private let sut = EpisodeCharacterWithEpisodesMapper()

	// MARK: - Standard Mapping

	@Test("Maps character with episodes from DTO to domain model")
	func mapsCharacterWithEpisodes() throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		let expected = EpisodeCharacterWithEpisodes.stub()

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}

	@Test("Maps character id from string to integer")
	func mapsCharacterId() throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.id == 1)
	}

	@Test("Maps character name")
	func mapsCharacterName() throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.name == "Rick Sanchez")
	}

	@Test("Maps character image URL")
	func mapsCharacterImageURL() throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.imageURL == URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"))
	}

	@Test("Maps non-numeric character id to zero")
	func mapsNonNumericCharacterIdToZero() {
		// Given
		let dto = EpisodeCharacterWithEpisodesDTO(id: "invalid", name: "", image: "", episodes: [])

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.id == 0)
	}

	@Test("Maps episodes count")
	func mapsEpisodesCount() throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.episodes.count == 2)
	}
}

// MARK: - Private

private extension EpisodeCharacterWithEpisodesMapperTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}
}

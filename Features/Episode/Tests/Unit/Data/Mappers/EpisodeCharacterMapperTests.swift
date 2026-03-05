import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct EpisodeCharacterMapperTests {
	// MARK: - Properties

	private let sut = EpisodeCharacterMapper()

	// MARK: - Standard Mapping

	@Test("Maps character from DTO to domain model")
	func mapsCharacter() throws {
		// Given
		let dto: EpisodeCharacterDTO = try loadJSON("episode_character")
		let expected = EpisodeCharacter.stub()

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}

	@Test("Maps character id from string to integer")
	func mapsCharacterId() throws {
		// Given
		let dto: EpisodeCharacterDTO = try loadJSON("episode_character_id_42")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.id == 42)
	}

	@Test("Maps invalid id to zero")
	func mapsInvalidIdToZero() throws {
		// Given
		let dto: EpisodeCharacterDTO = try loadJSON("episode_character_invalid_id")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.id == 0)
	}

	@Test("Maps valid image URL")
	func mapsValidImageURL() throws {
		// Given
		let dto: EpisodeCharacterDTO = try loadJSON("episode_character")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.imageURL == URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"))
	}
}

// MARK: - Private

private extension EpisodeCharacterMapperTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}
}

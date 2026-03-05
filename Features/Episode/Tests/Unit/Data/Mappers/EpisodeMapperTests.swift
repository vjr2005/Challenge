import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct EpisodeMapperTests {
	// MARK: - Properties

	private let sut = EpisodeMapper()

	// MARK: - Standard Mapping

	@Test("Maps episode from DTO to domain model")
	func mapsEpisode() throws {
		// Given
		let dto: EpisodeDTO = try loadJSON("episode")
		let expected = Episode.stub(
			characters: [.stub()]
		)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}

	@Test("Maps episode id from string to integer")
	func mapsEpisodeId() throws {
		// Given
		let dto: EpisodeDTO = try loadJSON("episode_id_42")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.id == 42)
	}

	@Test("Maps invalid id to zero")
	func mapsInvalidIdToZero() throws {
		// Given
		let dto: EpisodeDTO = try loadJSON("episode_invalid_id")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.id == 0)
	}

	@Test("Maps episode characters")
	func mapsEpisodeCharacters() throws {
		// Given
		let dto: EpisodeDTO = try loadJSON("episode_two_characters")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.characters.count == 2)
		#expect(result.characters[0].name == "Rick Sanchez")
		#expect(result.characters[1].name == "Morty Smith")
	}
}

// MARK: - Private

private extension EpisodeMapperTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}
}

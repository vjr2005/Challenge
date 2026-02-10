import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct EpisodeMapperTests {
	// MARK: - Properties

	private let sut = EpisodeMapper()

	// MARK: - Standard Mapping

	@Test("Maps episode from DTO to domain model")
	func mapsEpisode() {
		// Given
		let dto = EpisodeDTO(
			id: "1",
			name: "Pilot",
			airDate: "December 2, 2013",
			episode: "S01E01",
			characters: [
				EpisodeCharacterDTO(id: "1", name: "Rick Sanchez", image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
			]
		)
		let expected = Episode.stub(
			characters: [.stub()]
		)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}

	@Test("Maps episode id from string to integer")
	func mapsEpisodeId() {
		// Given
		let dto = EpisodeDTO(
			id: "42",
			name: "Test",
			airDate: "January 1, 2020",
			episode: "S01E01",
			characters: []
		)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.id == 42)
	}

	@Test("Maps invalid id to zero")
	func mapsInvalidIdToZero() {
		// Given
		let dto = EpisodeDTO(
			id: "invalid",
			name: "Test",
			airDate: "January 1, 2020",
			episode: "S01E01",
			characters: []
		)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.id == 0)
	}

	@Test("Maps episode characters")
	func mapsEpisodeCharacters() {
		// Given
		let dto = EpisodeDTO(
			id: "1",
			name: "Pilot",
			airDate: "December 2, 2013",
			episode: "S01E01",
			characters: [
				EpisodeCharacterDTO(id: "1", name: "Rick Sanchez", image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
				EpisodeCharacterDTO(id: "2", name: "Morty Smith", image: "https://rickandmortyapi.com/api/character/avatar/2.jpeg")
			]
		)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.characters.count == 2)
		#expect(result.characters[0].name == "Rick Sanchez")
		#expect(result.characters[1].name == "Morty Smith")
	}
}

import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct EpisodeCharacterMapperTests {
	// MARK: - Properties

	private let sut = EpisodeCharacterMapper()

	// MARK: - Standard Mapping

	@Test("Maps character from DTO to domain model")
	func mapsCharacter() {
		// Given
		let dto = EpisodeCharacterDTO(
			id: "1",
			name: "Rick Sanchez",
			image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"
		)
		let expected = EpisodeCharacter.stub()

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}

	@Test("Maps character id from string to integer")
	func mapsCharacterId() {
		// Given
		let dto = EpisodeCharacterDTO(
			id: "42",
			name: "Test",
			image: "https://example.com/image.jpeg"
		)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.id == 42)
	}

	@Test("Maps invalid id to zero")
	func mapsInvalidIdToZero() {
		// Given
		let dto = EpisodeCharacterDTO(
			id: "invalid",
			name: "Test",
			image: "https://example.com/image.jpeg"
		)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.id == 0)
	}

	@Test("Maps valid image URL")
	func mapsValidImageURL() {
		// Given
		let dto = EpisodeCharacterDTO(
			id: "1",
			name: "Test",
			image: "https://example.com/image.jpeg"
		)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.imageURL == URL(string: "https://example.com/image.jpeg"))
	}
}

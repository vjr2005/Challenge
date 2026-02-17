import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterEntityMapperTests {
	// MARK: - Properties

	private let sut = CharacterEntityMapper()

	// MARK: - Standard Mapping

	@Test("Maps all properties from DTO to entity")
	func mapsAllProperties() throws {
		// Given
		let dto: CharacterDTO = try loadJSON("character")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.identifier == dto.id)
		#expect(result.name == dto.name)
		#expect(result.status == dto.status)
		#expect(result.species == dto.species)
		#expect(result.type == dto.type)
		#expect(result.gender == dto.gender)
		#expect(result.image == dto.image)
		#expect(result.episode == dto.episode)
		#expect(result.url == dto.url)
		#expect(result.created == dto.created)
	}

	// MARK: - Location Mapping

	@Test("Maps origin location from DTO to entity")
	func mapsOriginLocation() throws {
		// Given
		let dto: CharacterDTO = try loadJSON("character")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.origin.name == dto.origin.name)
		#expect(result.origin.url == dto.origin.url)
	}

	@Test("Maps current location from DTO to entity")
	func mapsCurrentLocation() throws {
		// Given
		let dto: CharacterDTO = try loadJSON("character")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.location.name == dto.location.name)
		#expect(result.location.url == dto.location.url)
	}

	@Test("Maps empty origin URL from DTO to entity")
	func mapsEmptyOriginURL() throws {
		// Given
		let dto: CharacterDTO = try loadJSON("character_2")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.origin.name == "unknown")
		#expect(result.origin.url == "")
	}

	// MARK: - Multiple Episodes

	@Test("Maps multiple episodes from DTO to entity")
	func mapsMultipleEpisodes() throws {
		// Given
		let dto: CharacterDTO = try loadJSON("character_2")

		// When
		let result = sut.map(dto)

		// Then
		#expect(result.episode.count == 2)
		#expect(result.episode == dto.episode)
	}
}

// MARK: - Private

private extension CharacterEntityMapperTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}
}

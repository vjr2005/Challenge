import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterEntityDTOMapperTests {
	// MARK: - Properties

	private let sut = CharacterEntityDTOMapper()

	// MARK: - Standard Mapping

	@Test("Maps all properties from entity to DTO")
	func mapsAllProperties() {
		// Given
		let entity = makeEntity()

		// When
		let result = sut.map(entity)

		// Then
		#expect(result.id == entity.identifier)
		#expect(result.name == entity.name)
		#expect(result.status == entity.status)
		#expect(result.species == entity.species)
		#expect(result.type == entity.type)
		#expect(result.gender == entity.gender)
		#expect(result.image == entity.image)
		#expect(result.episode == entity.episode)
		#expect(result.url == entity.url)
		#expect(result.created == entity.created)
	}

	// MARK: - Location Mapping

	@Test("Maps origin location from entity to DTO")
	func mapsOriginLocation() {
		// Given
		let entity = makeEntity()

		// When
		let result = sut.map(entity)

		// Then
		#expect(result.origin.name == entity.origin.name)
		#expect(result.origin.url == entity.origin.url)
	}

	@Test("Maps current location from entity to DTO")
	func mapsCurrentLocation() {
		// Given
		let entity = makeEntity()

		// When
		let result = sut.map(entity)

		// Then
		#expect(result.location.name == entity.location.name)
		#expect(result.location.url == entity.location.url)
	}

	// MARK: - Round-Trip Consistency

	@Test("DTO to entity to DTO produces equivalent result")
	func roundTripConsistency() throws {
		// Given
		let originalDTO: CharacterDTO = try loadJSON("character")
		let entityMapper = CharacterEntityMapper()

		// When
		let entity = entityMapper.map(originalDTO)
		let result = sut.map(entity)

		// Then
		#expect(result == originalDTO)
	}

	@Test("Round-trip preserves multiple episodes")
	func roundTripPreservesMultipleEpisodes() throws {
		// Given
		let originalDTO: CharacterDTO = try loadJSON("character_2")
		let entityMapper = CharacterEntityMapper()

		// When
		let entity = entityMapper.map(originalDTO)
		let result = sut.map(entity)

		// Then
		#expect(result == originalDTO)
	}
}

// MARK: - Private

private extension CharacterEntityDTOMapperTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}

	func makeEntity() -> CharacterEntity {
		CharacterEntity(
			identifier: 1,
			name: "Rick Sanchez",
			status: "Alive",
			species: "Human",
			type: "",
			gender: "Male",
			origin: LocationEntity(name: "Earth (C-137)", url: "https://rickandmortyapi.com/api/location/1"),
			location: LocationEntity(name: "Citadel of Ricks", url: "https://rickandmortyapi.com/api/location/3"),
			image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
			episode: ["https://rickandmortyapi.com/api/episode/1"],
			url: "https://rickandmortyapi.com/api/character/1",
			created: "2017-11-04T18:48:46.250Z"
		)
	}
}

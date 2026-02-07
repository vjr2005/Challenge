import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterMapperTests {
	// MARK: - Properties

	private let sut = CharacterMapper()

	// MARK: - Standard Mapping

	@Test("Maps standard character from DTO to domain model")
	func mapsStandardCharacter() throws {
		// Given
		let dto: CharacterDTO = try loadJSON("character")
		let expected = Character.stub()

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}

	// MARK: - Status Mapping

	@Test("Maps dead status from DTO to domain model")
	func mapsDeadStatus() throws {
		// Given
		let dto: CharacterDTO = try loadJSON("character_dead")
		let expected = Character.stub(status: .dead)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}

	@Test("Maps unknown status from DTO to domain model")
	func mapsUnknownStatus() throws {
		// Given
		let dto: CharacterDTO = try loadJSON("character_unknown_status")
		let expected = Character.stub(status: .unknown)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}

	// MARK: - Gender Mapping

	@Test("Maps female gender from DTO to domain model")
	func mapsFemaleGender() throws {
		// Given
		let dto: CharacterDTO = try loadJSON("character_female")
		let expected = Character.stub(gender: .female)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}

	@Test("Maps genderless gender from DTO to domain model")
	func mapsGenderlessGender() throws {
		// Given
		let dto: CharacterDTO = try loadJSON("character_genderless")
		let expected = Character.stub(gender: .genderless)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}

	@Test("Maps unknown gender from DTO to domain model")
	func mapsUnknownGender() throws {
		// Given
		let dto: CharacterDTO = try loadJSON("character_unknown_gender")
		let expected = Character.stub(gender: .unknown)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}
}

// MARK: - Private

private extension CharacterMapperTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}
}

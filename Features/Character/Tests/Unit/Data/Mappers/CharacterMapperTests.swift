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

	@Test("Maps status from DTO to domain model", arguments: [
		("character_dead", CharacterStatus.dead),
		("character_unknown_status", CharacterStatus.unknown)
	])
	func mapsStatus(fixture: String, expectedStatus: CharacterStatus) throws {
		// Given
		let dto: CharacterDTO = try loadJSON(fixture)
		let expected = Character.stub(status: expectedStatus)

		// When
		let result = sut.map(dto)

		// Then
		#expect(result == expected)
	}

	// MARK: - Gender Mapping

	@Test("Maps gender from DTO to domain model", arguments: [
		("character_female", CharacterGender.female),
		("character_genderless", CharacterGender.genderless),
		("character_unknown_gender", CharacterGender.unknown)
	])
	func mapsGender(fixture: String, expectedGender: CharacterGender) throws {
		// Given
		let dto: CharacterDTO = try loadJSON(fixture)
		let expected = Character.stub(gender: expectedGender)

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

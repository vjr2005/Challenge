import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterFilterMapperTests {
	// MARK: - Properties

	private let sut = CharacterFilterMapper()

	// MARK: - Empty Filter

	@Test("Maps empty filter to empty DTO")
	func mapsEmptyFilterToEmptyDTO() {
		// Given
		let filter = CharacterFilter()

		// When
		let result = sut.map(filter)

		// Then
		#expect(result == .empty)
	}

	// MARK: - Name Mapping

	@Test("Maps name field from domain to DTO")
	func mapsNameField() {
		// Given
		let filter = CharacterFilter(name: "Rick")

		// When
		let result = sut.map(filter)

		// Then
		#expect(result == CharacterFilterDTO(name: "Rick"))
	}

	// MARK: - Status Mapping

	@Test("Maps alive status to lowercased string", arguments: [
		(CharacterStatus.alive, "alive"),
		(CharacterStatus.dead, "dead"),
		(CharacterStatus.unknown, "unknown"),
	])
	func mapsStatus(status: CharacterStatus, expected: String) {
		// Given
		let filter = CharacterFilter(status: status)

		// When
		let result = sut.map(filter)

		// Then
		#expect(result == CharacterFilterDTO(status: expected))
	}

	// MARK: - Gender Mapping

	@Test("Maps gender to lowercased string", arguments: [
		(CharacterGender.female, "female"),
		(CharacterGender.male, "male"),
		(CharacterGender.genderless, "genderless"),
		(CharacterGender.unknown, "unknown"),
	])
	func mapsGender(gender: CharacterGender, expected: String) {
		// Given
		let filter = CharacterFilter(gender: gender)

		// When
		let result = sut.map(filter)

		// Then
		#expect(result == CharacterFilterDTO(gender: expected))
	}

	// MARK: - Species and Type Mapping

	@Test("Maps species field from domain to DTO")
	func mapsSpeciesField() {
		// Given
		let filter = CharacterFilter(species: "Human")

		// When
		let result = sut.map(filter)

		// Then
		#expect(result == CharacterFilterDTO(species: "Human"))
	}

	@Test("Maps type field from domain to DTO")
	func mapsTypeField() {
		// Given
		let filter = CharacterFilter(type: "Parasite")

		// When
		let result = sut.map(filter)

		// Then
		#expect(result == CharacterFilterDTO(type: "Parasite"))
	}

	// MARK: - Full Filter Mapping

	@Test("Maps all fields together from domain to DTO")
	func mapsAllFieldsTogether() {
		// Given
		let filter = CharacterFilter(
			name: "Rick",
			status: .alive,
			species: "Human",
			type: "Scientist",
			gender: .male
		)

		// When
		let result = sut.map(filter)

		// Then
		let expected = CharacterFilterDTO(
			name: "Rick",
			status: "alive",
			species: "Human",
			type: "Scientist",
			gender: "male"
		)
		#expect(result == expected)
	}
}

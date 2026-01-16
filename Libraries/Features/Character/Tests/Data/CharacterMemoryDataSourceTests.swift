import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterMemoryDataSourceTests {
	@Test
	func savesAndRetrievesCharacter() async {
		// Given
		let expected = CharacterDTO.stub()
		let sut = CharacterMemoryDataSource()

		// When
		await sut.saveCharacter(expected)
		let value = await sut.getCharacter(identifier: expected.id)

		// Then
		#expect(value == expected)
	}

	@Test
	func returnsNilForNonExistentCharacter() async {
		// Given
		let sut = CharacterMemoryDataSource()

		// When
		let value = await sut.getCharacter(identifier: 999)

		// Then
		#expect(value == nil)
	}

	@Test
	func savesMultipleCharacters() async {
		// Given
		let characters = [CharacterDTO.stub(id: 1), CharacterDTO.stub(id: 2)]
		let sut = CharacterMemoryDataSource()

		// When
		await sut.saveCharacters(characters)
		let value = await sut.getAllCharacters()

		// Then
		#expect(value.count == 2)
	}

	@Test
	func deletesCharacter() async {
		// Given
		let character = CharacterDTO.stub()
		let sut = CharacterMemoryDataSource()
		await sut.saveCharacter(character)

		// When
		await sut.deleteCharacter(identifier: character.id)
		let value = await sut.getCharacter(identifier: character.id)

		// Then
		#expect(value == nil)
	}

	@Test
	func deletesAllCharacters() async {
		// Given
		let characters = [CharacterDTO.stub(id: 1), CharacterDTO.stub(id: 2)]
		let sut = CharacterMemoryDataSource()
		await sut.saveCharacters(characters)

		// When
		await sut.deleteAllCharacters()
		let value = await sut.getAllCharacters()

		// Then
		#expect(value.isEmpty)
	}

	@Test
	func updatesExistingCharacter() async {
		// Given
		let original = CharacterDTO.stub(id: 1, name: "Rick Sanchez")
		let updated = CharacterDTO.stub(id: 1, name: "Evil Rick")
		let sut = CharacterMemoryDataSource()
		await sut.saveCharacter(original)

		// When
		await sut.saveCharacter(updated)
		let value = await sut.getCharacter(identifier: 1)

		// Then
		#expect(value == updated)
	}
}

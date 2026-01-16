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

	// MARK: - Page Caching Tests

	@Test
	func savesAndRetrievesPage() async {
		// Given
		let expected = CharactersResponseDTO.stub()
		let sut = CharacterMemoryDataSource()

		// When
		await sut.savePage(expected, page: 1)
		let value = await sut.getPage(1)

		// Then
		#expect(value == expected)
	}

	@Test
	func returnsNilForNonExistentPage() async {
		// Given
		let sut = CharacterMemoryDataSource()

		// When
		let value = await sut.getPage(999)

		// Then
		#expect(value == nil)
	}

	@Test
	func savePageAlsoSavesIndividualCharacters() async {
		// Given
		let characters = [CharacterDTO.stub(id: 1), CharacterDTO.stub(id: 2)]
		let response = CharactersResponseDTO.stub(results: characters)
		let sut = CharacterMemoryDataSource()

		// When
		await sut.savePage(response, page: 1)
		let character1 = await sut.getCharacter(identifier: 1)
		let character2 = await sut.getCharacter(identifier: 2)

		// Then
		#expect(character1 == characters[0])
		#expect(character2 == characters[1])
	}

	@Test
	func deletesPage() async {
		// Given
		let response = CharactersResponseDTO.stub()
		let sut = CharacterMemoryDataSource()
		await sut.savePage(response, page: 1)

		// When
		await sut.deletePage(1)
		let value = await sut.getPage(1)

		// Then
		#expect(value == nil)
	}

	@Test
	func deletesAllPages() async {
		// Given
		let response = CharactersResponseDTO.stub()
		let sut = CharacterMemoryDataSource()
		await sut.savePage(response, page: 1)
		await sut.savePage(response, page: 2)

		// When
		await sut.deleteAllPages()
		let page1 = await sut.getPage(1)
		let page2 = await sut.getPage(2)

		// Then
		#expect(page1 == nil)
		#expect(page2 == nil)
	}

	@Test
	func differentPagesAreCachedSeparately() async {
		// Given
		let page1Response = CharactersResponseDTO.stub(
			info: .stub(next: "page2"),
			results: [.stub(id: 1)]
		)
		let page2Response = CharactersResponseDTO.stub(
			info: .stub(prev: "page1"),
			results: [.stub(id: 2)]
		)
		let sut = CharacterMemoryDataSource()

		// When
		await sut.savePage(page1Response, page: 1)
		await sut.savePage(page2Response, page: 2)
		let cachedPage1 = await sut.getPage(1)
		let cachedPage2 = await sut.getPage(2)

		// Then
		#expect(cachedPage1 == page1Response)
		#expect(cachedPage2 == page2Response)
	}
}

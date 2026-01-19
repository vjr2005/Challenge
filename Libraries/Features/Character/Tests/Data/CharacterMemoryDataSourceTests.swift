import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterMemoryDataSourceTests {
	private let testBundle = Bundle(for: BundleToken.self)

	@Test
	func savesAndRetrievesCharacter() async throws {
		// Given
		let expected: CharacterDTO = try testBundle.loadJSON("character", as: CharacterDTO.self)
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
	func savesMultipleCharacters() async throws {
		// Given
		let character1: CharacterDTO = try testBundle.loadJSON("character", as: CharacterDTO.self)
		let character2: CharacterDTO = try testBundle.loadJSON("character_2", as: CharacterDTO.self)
		let characters = [character1, character2]
		let sut = CharacterMemoryDataSource()

		// When
		await sut.saveCharacters(characters)
		let value = await sut.getAllCharacters()

		// Then
		#expect(value.count == 2)
	}

	@Test
	func deletesCharacter() async throws {
		// Given
		let character: CharacterDTO = try testBundle.loadJSON("character", as: CharacterDTO.self)
		let sut = CharacterMemoryDataSource()
		await sut.saveCharacter(character)

		// When
		await sut.deleteCharacter(identifier: character.id)
		let value = await sut.getCharacter(identifier: character.id)

		// Then
		#expect(value == nil)
	}

	@Test
	func deletesAllCharacters() async throws {
		// Given
		let character1: CharacterDTO = try testBundle.loadJSON("character", as: CharacterDTO.self)
		let character2: CharacterDTO = try testBundle.loadJSON("character_2", as: CharacterDTO.self)
		let characters = [character1, character2]
		let sut = CharacterMemoryDataSource()
		await sut.saveCharacters(characters)

		// When
		await sut.deleteAllCharacters()
		let value = await sut.getAllCharacters()

		// Then
		#expect(value.isEmpty)
	}

	@Test
	func updatesExistingCharacter() async throws {
		// Given
		let original: CharacterDTO = try testBundle.loadJSON("character", as: CharacterDTO.self)
		let updated: CharacterDTO = try testBundle.loadJSON("character_dead", as: CharacterDTO.self)
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
	func savesAndRetrievesPage() async throws {
		// Given
		let expected: CharactersResponseDTO = try testBundle.loadJSON("characters_response", as: CharactersResponseDTO.self)
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
	func savePageAlsoSavesIndividualCharacters() async throws {
		// Given
		let response: CharactersResponseDTO = try testBundle.loadJSON("characters_response_two_results", as: CharactersResponseDTO.self)
		let sut = CharacterMemoryDataSource()

		// When
		await sut.savePage(response, page: 1)
		let character1 = await sut.getCharacter(identifier: 1)
		let character2 = await sut.getCharacter(identifier: 2)

		// Then
		#expect(character1 == response.results[0])
		#expect(character2 == response.results[1])
	}

	@Test
	func deletesPage() async throws {
		// Given
		let response: CharactersResponseDTO = try testBundle.loadJSON("characters_response", as: CharactersResponseDTO.self)
		let sut = CharacterMemoryDataSource()
		await sut.savePage(response, page: 1)

		// When
		await sut.deletePage(1)
		let value = await sut.getPage(1)

		// Then
		#expect(value == nil)
	}

	@Test
	func deletesAllPages() async throws {
		// Given
		let response: CharactersResponseDTO = try testBundle.loadJSON("characters_response", as: CharactersResponseDTO.self)
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
	func differentPagesAreCachedSeparately() async throws {
		// Given
		let page1Response: CharactersResponseDTO = try testBundle.loadJSON("characters_response", as: CharactersResponseDTO.self)
		let page2Response: CharactersResponseDTO = try testBundle.loadJSON("characters_response_page_2", as: CharactersResponseDTO.self)
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

private final class BundleToken {}

import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterMemoryDataSourceTests {
	@Test
	func savesAndRetrievesCharacter() async throws {
		// Given
        let expected: CharacterDTO = try loadJSON("character")
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
	func updatesExistingCharacter() async throws {
		// Given
		let original: CharacterDTO = try loadJSON("character")
		let updated: CharacterDTO = try loadJSON("character_dead")
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
		let expected: CharactersResponseDTO = try loadJSON("characters_response")
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
		let response: CharactersResponseDTO = try loadJSON("characters_response_two_results")
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
	func differentPagesAreCachedSeparately() async throws {
		// Given
		let page1Response: CharactersResponseDTO = try loadJSON("characters_response")
		let page2Response: CharactersResponseDTO = try loadJSON("characters_response_page_2")
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

	// MARK: - Clear Pages Tests

	@Test
	func clearPagesRemovesAllCachedPages() async throws {
		// Given
		let page1Response: CharactersResponseDTO = try loadJSON("characters_response")
		let page2Response: CharactersResponseDTO = try loadJSON("characters_response_page_2")
		let sut = CharacterMemoryDataSource()
		await sut.savePage(page1Response, page: 1)
		await sut.savePage(page2Response, page: 2)

		// When
		await sut.clearPages()

		// Then
		let cachedPage1 = await sut.getPage(1)
		let cachedPage2 = await sut.getPage(2)
		#expect(cachedPage1 == nil)
		#expect(cachedPage2 == nil)
	}

	@Test
	func clearPagesKeepsIndividualCharacters() async throws {
		// Given
		let character: CharacterDTO = try loadJSON("character")
		let pageResponse: CharactersResponseDTO = try loadJSON("characters_response")
		let sut = CharacterMemoryDataSource()
		await sut.saveCharacter(character)
		await sut.savePage(pageResponse, page: 1)

		// When
		await sut.clearPages()

		// Then
		let cachedCharacter = await sut.getCharacter(identifier: character.id)
		#expect(cachedCharacter == character)
	}

	// MARK: - Update Character In Pages Tests

	@Test
	func updateCharacterInPagesUpdatesCharacterStorage() async throws {
		// Given
		let original: CharacterDTO = try loadJSON("character")
		let updated: CharacterDTO = try loadJSON("character_dead")
		let sut = CharacterMemoryDataSource()
		await sut.saveCharacter(original)

		// When
		await sut.updateCharacterInPages(updated)

		// Then
		let cachedCharacter = await sut.getCharacter(identifier: updated.id)
		#expect(cachedCharacter == updated)
	}

	@Test
	func updateCharacterInPagesUpdatesCharacterInCachedPage() async throws {
		// Given
		let pageResponse: CharactersResponseDTO = try loadJSON("characters_response")
		let updatedCharacter: CharacterDTO = try loadJSON("character_dead")
		let sut = CharacterMemoryDataSource()
		await sut.savePage(pageResponse, page: 1)

		// When
		await sut.updateCharacterInPages(updatedCharacter)

		// Then
		let cachedPage = await sut.getPage(1)
		let characterInPage = cachedPage?.results.first { $0.id == updatedCharacter.id }
		#expect(characterInPage == updatedCharacter)
	}

	@Test
	func updateCharacterInPagesUpdatesCharacterInMultiplePages() async throws {
		// Given
		let page1Response: CharactersResponseDTO = try loadJSON("characters_response")
		let page2Response: CharactersResponseDTO = try loadJSON("characters_response_page_2")
		let updatedCharacter: CharacterDTO = try loadJSON("character_dead")
		let sut = CharacterMemoryDataSource()
		await sut.savePage(page1Response, page: 1)
		await sut.savePage(page2Response, page: 2)

		// When
		await sut.updateCharacterInPages(updatedCharacter)

		// Then
		let cachedPage1 = await sut.getPage(1)
		let characterInPage1 = cachedPage1?.results.first { $0.id == updatedCharacter.id }
		#expect(characterInPage1 == updatedCharacter)
	}

	@Test
	func updateCharacterInPagesDoesNotAffectOtherCharacters() async throws {
		// Given
		let pageResponse: CharactersResponseDTO = try loadJSON("characters_response_two_results")
		let updatedCharacter: CharacterDTO = try loadJSON("character_dead")
		let sut = CharacterMemoryDataSource()
		await sut.savePage(pageResponse, page: 1)
		let otherCharacterId = pageResponse.results[1].id

		// When
		await sut.updateCharacterInPages(updatedCharacter)

		// Then
		let cachedPage = await sut.getPage(1)
		let otherCharacter = cachedPage?.results.first { $0.id == otherCharacterId }
		#expect(otherCharacter == pageResponse.results[1])
	}
}

// MARK: - Private

private extension CharacterMemoryDataSourceTests {
    func loadJSON<T: Decodable>(_ filename: String) throws -> T {
        try Bundle.module.loadJSON(filename)
    }
}

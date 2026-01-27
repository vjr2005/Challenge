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
}

// MARK: - Private

private extension CharacterMemoryDataSourceTests {
    func loadJSON<T: Decodable>(_ filename: String) throws -> T {
        try Bundle.module.loadJSON(filename)
    }
}

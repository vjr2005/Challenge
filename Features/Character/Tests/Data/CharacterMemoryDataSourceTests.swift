import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
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

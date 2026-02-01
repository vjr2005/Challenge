import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterMemoryDataSourceTests {
    // MARK: - Properties

    private let sut = CharacterMemoryDataSource()

    // MARK: - Character Tests

    @Test("Saves and retrieves character from memory")
    func savesAndRetrievesCharacter() async throws {
        // Given
        let expected: CharacterDTO = try loadJSON("character")

        // When
        await sut.saveCharacter(expected)
        let value = await sut.getCharacter(identifier: expected.id)

        // Then
        #expect(value == expected)
    }

    @Test("Returns nil for non-existent character")
    func returnsNilForNonExistentCharacter() async {
        // When
        let value = await sut.getCharacter(identifier: 999)

        // Then
        #expect(value == nil)
    }

    @Test("Updates existing character in memory")
    func updatesExistingCharacter() async throws {
        // Given
        let original: CharacterDTO = try loadJSON("character")
        let updated: CharacterDTO = try loadJSON("character_dead")
        await sut.saveCharacter(original)

        // When
        await sut.saveCharacter(updated)
        let value = await sut.getCharacter(identifier: 1)

        // Then
        #expect(value == updated)
    }

    // MARK: - Page Caching Tests

    @Test("Saves and retrieves page from memory")
    func savesAndRetrievesPage() async throws {
        // Given
        let expected: CharactersResponseDTO = try loadJSON("characters_response")

        // When
        await sut.savePage(expected, page: 1)
        let value = await sut.getPage(1)

        // Then
        #expect(value == expected)
    }

    @Test("Returns nil for non-existent page")
    func returnsNilForNonExistentPage() async {
        // When
        let value = await sut.getPage(999)

        // Then
        #expect(value == nil)
    }

    @Test("Save page also saves individual characters")
    func savePageAlsoSavesIndividualCharacters() async throws {
        // Given
        let response: CharactersResponseDTO = try loadJSON("characters_response_two_results")

        // When
        await sut.savePage(response, page: 1)
        let character1 = await sut.getCharacter(identifier: 1)
        let character2 = await sut.getCharacter(identifier: 2)

        // Then
        #expect(character1 == response.results[0])
        #expect(character2 == response.results[1])
    }

    @Test("Different pages are cached separately")
    func differentPagesAreCachedSeparately() async throws {
        // Given
        let page1Response: CharactersResponseDTO = try loadJSON("characters_response")
        let page2Response: CharactersResponseDTO = try loadJSON("characters_response_page_2")

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

    @Test("Clear pages removes all cached pages")
    func clearPagesRemovesAllCachedPages() async throws {
        // Given
        let page1Response: CharactersResponseDTO = try loadJSON("characters_response")
        let page2Response: CharactersResponseDTO = try loadJSON("characters_response_page_2")
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

    @Test("Clear pages keeps individual characters")
    func clearPagesKeepsIndividualCharacters() async throws {
        // Given
        let character: CharacterDTO = try loadJSON("character")
        let pageResponse: CharactersResponseDTO = try loadJSON("characters_response")
        await sut.saveCharacter(character)
        await sut.savePage(pageResponse, page: 1)

        // When
        await sut.clearPages()

        // Then
        let cachedCharacter = await sut.getCharacter(identifier: character.id)
        #expect(cachedCharacter == character)
    }

    // MARK: - Update Character In Pages Tests

    @Test("Update character in pages updates character storage")
    func updateCharacterInPagesUpdatesCharacterStorage() async throws {
        // Given
        let original: CharacterDTO = try loadJSON("character")
        let updated: CharacterDTO = try loadJSON("character_dead")
        await sut.saveCharacter(original)

        // When
        await sut.updateCharacterInPages(updated)

        // Then
        let cachedCharacter = await sut.getCharacter(identifier: updated.id)
        #expect(cachedCharacter == updated)
    }

    @Test("Update character in pages updates character in cached page")
    func updateCharacterInPagesUpdatesCharacterInCachedPage() async throws {
        // Given
        let pageResponse: CharactersResponseDTO = try loadJSON("characters_response")
        let updatedCharacter: CharacterDTO = try loadJSON("character_dead")
        await sut.savePage(pageResponse, page: 1)

        // When
        await sut.updateCharacterInPages(updatedCharacter)

        // Then
        let cachedPage = await sut.getPage(1)
        let characterInPage = cachedPage?.results.first { $0.id == updatedCharacter.id }
        #expect(characterInPage == updatedCharacter)
    }

    @Test("Update character in pages updates character in multiple pages")
    func updateCharacterInPagesUpdatesCharacterInMultiplePages() async throws {
        // Given
        let page1Response: CharactersResponseDTO = try loadJSON("characters_response")
        let page2Response: CharactersResponseDTO = try loadJSON("characters_response_page_2")
        let updatedCharacter: CharacterDTO = try loadJSON("character_dead")
        await sut.savePage(page1Response, page: 1)
        await sut.savePage(page2Response, page: 2)

        // When
        await sut.updateCharacterInPages(updatedCharacter)

        // Then
        let cachedPage1 = await sut.getPage(1)
        let characterInPage1 = cachedPage1?.results.first { $0.id == updatedCharacter.id }
        #expect(characterInPage1 == updatedCharacter)
    }

    @Test("Update character in pages does not affect other characters")
    func updateCharacterInPagesDoesNotAffectOtherCharacters() async throws {
        // Given
        let pageResponse: CharactersResponseDTO = try loadJSON("characters_response_two_results")
        let updatedCharacter: CharacterDTO = try loadJSON("character_dead")
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

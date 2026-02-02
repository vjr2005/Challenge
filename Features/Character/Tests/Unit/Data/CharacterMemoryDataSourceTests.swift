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
        await sut.saveCharacterDetail(expected)
        let value = await sut.getCharacterDetail(identifier: expected.id)

        // Then
        #expect(value == expected)
    }

    @Test("Returns nil for non-existent character")
    func returnsNilForNonExistentCharacter() async {
        // When
        let value = await sut.getCharacterDetail(identifier: 999)

        // Then
        #expect(value == nil)
    }

    @Test("Updates existing character in memory")
    func updatesExistingCharacter() async throws {
        // Given
        let original: CharacterDTO = try loadJSON("character")
        let updated: CharacterDTO = try loadJSON("character_dead")
        await sut.saveCharacterDetail(original)

        // When
        await sut.saveCharacterDetail(updated)
        let value = await sut.getCharacterDetail(identifier: 1)

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

    @Test("Save page does not save individual characters")
    func savePageDoesNotSaveIndividualCharacters() async throws {
        // Given
        let response: CharactersResponseDTO = try loadJSON("characters_response_two_results")

        // When
        await sut.savePage(response, page: 1)
        let character1 = await sut.getCharacterDetail(identifier: 1)
        let character2 = await sut.getCharacterDetail(identifier: 2)

        // Then
        #expect(character1 == nil)
        #expect(character2 == nil)
    }
}

// MARK: - Private

private extension CharacterMemoryDataSourceTests {
    func loadJSON<T: Decodable>(_ filename: String) throws -> T {
        try Bundle.module.loadJSON(filename)
    }
}

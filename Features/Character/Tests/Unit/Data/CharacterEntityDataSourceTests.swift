import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterEntityDataSourceTests {
	// MARK: - Properties

	private let sut: CharacterEntityDataSource

	// MARK: - Initialization

	init() {
		let container = CharacterModelContainer.create(inMemoryOnly: true)
		sut = CharacterEntityDataSource(modelContainer: container)
	}

	// MARK: - getCharacter

	@Test("Returns nil when character does not exist")
	func getCharacterReturnsNilWhenNotFound() async {
		// When
		let result = await sut.getCharacter(identifier: 999)

		// Then
		#expect(result == nil)
	}

	@Test("Returns character after saving")
	func getCharacterReturnsAfterSaving() async throws {
		// Given
		let dto: CharacterDTO = try loadJSON("character")
		await sut.saveCharacter(dto)

		// When
		let result = await sut.getCharacter(identifier: dto.id)

		// Then
		#expect(result == dto)
	}

	@Test("Returns correct character by identifier")
	func getCharacterReturnsCorrectByIdentifier() async throws {
		// Given
		let rick: CharacterDTO = try loadJSON("character")
		let morty: CharacterDTO = try loadJSON("character_2")
		await sut.saveCharacter(rick)
		await sut.saveCharacter(morty)

		// When
		let result = await sut.getCharacter(identifier: morty.id)

		// Then
		#expect(result == morty)
	}

	// MARK: - saveCharacter

	@Test("Upserts character with same identifier")
	func saveCharacterUpsertsExisting() async throws {
		// Given
		let original: CharacterDTO = try loadJSON("character")
		await sut.saveCharacter(original)

		let updated = CharacterDTO(
			id: original.id,
			name: "Rick Sanchez Updated",
			status: original.status,
			species: original.species,
			type: original.type,
			gender: original.gender,
			origin: original.origin,
			location: original.location,
			image: original.image,
			episode: original.episode,
			url: original.url,
			created: original.created
		)

		// When
		await sut.saveCharacter(updated)

		// Then
		let result = await sut.getCharacter(identifier: original.id)
		#expect(result?.name == "Rick Sanchez Updated")
	}

	// MARK: - getPage

	@Test("Returns nil when page does not exist")
	func getPageReturnsNilWhenNotFound() async {
		// When
		let result = await sut.getPage(1)

		// Then
		#expect(result == nil)
	}

	@Test("Returns page after saving")
	func getPageReturnsAfterSaving() async throws {
		// Given
		let response: CharactersResponseDTO = try loadJSON("characters_response")
		await sut.savePage(response, page: 1)

		// When
		let result = await sut.getPage(1)

		// Then
		#expect(result?.info.count == response.info.count)
		#expect(result?.info.pages == response.info.pages)
		#expect(result?.info.next == response.info.next)
		#expect(result?.info.prev == response.info.prev)
		#expect(result?.results.count == response.results.count)
		#expect(result?.results.first?.id == response.results.first?.id)
	}

	@Test("Returns correct page by number")
	func getPageReturnsCorrectByNumber() async throws {
		// Given
		let page1: CharactersResponseDTO = try loadJSON("characters_response")
		let page2: CharactersResponseDTO = try loadJSON("characters_response_two_results")
		await sut.savePage(page1, page: 1)
		await sut.savePage(page2, page: 2)

		// When
		let result = await sut.getPage(2)

		// Then
		#expect(result?.results.count == 2)
	}

	// MARK: - savePage

	@Test("Replaces existing page with same number")
	func savePageReplacesExisting() async {
		// Given
		let page1Character = makeCharacterDTO(id: 10, name: "Page 1 Character")
		let page1 = makeResponseDTO(characters: [page1Character])
		await sut.savePage(page1, page: 1)

		let page2Char1 = makeCharacterDTO(id: 20, name: "Replacement A")
		let page2Char2 = makeCharacterDTO(id: 21, name: "Replacement B")
		let replacement = makeResponseDTO(characters: [page2Char1, page2Char2])

		// When
		await sut.savePage(replacement, page: 1)

		// Then
		let result = await sut.getPage(1)
		#expect(result?.results.count == 2)
	}

	@Test("Characters persist independently from page")
	func charactersPersistIndependentlyFromPage() async throws {
		// Given
		let response: CharactersResponseDTO = try loadJSON("characters_response")
		await sut.savePage(response, page: 1)

		let replacement = CharactersResponseDTO(
			info: PaginationInfoDTO(count: 0, pages: 0, next: nil, prev: nil),
			results: []
		)
		// When
		await sut.savePage(replacement, page: 1)

		// Then — character still exists even after page was replaced
		let character = await sut.getCharacter(identifier: response.results[0].id)
		#expect(character != nil)
	}

	// MARK: - searchCharacters

	@Test("Returns nil when no characters match")
	func searchReturnsNilWhenNoMatch() async {
		// When
		let result = await sut.searchCharacters(
			page: 1,
			filter: CharacterFilterDTO(name: "NonExistent")
		)

		// Then
		#expect(result == nil)
	}

	@Test("Searches by name case-insensitively")
	func searchesByNameCaseInsensitive() async throws {
		// Given
		let rick: CharacterDTO = try loadJSON("character")
		await sut.saveCharacter(rick)

		// When
		let result = await sut.searchCharacters(
			page: 1,
			filter: CharacterFilterDTO(name: "rick")
		)

		// Then
		#expect(result?.results.count == 1)
		#expect(result?.results.first?.name == "Rick Sanchez")
	}

	@Test("Searches by partial name match")
	func searchesByPartialName() async throws {
		// Given
		let rick: CharacterDTO = try loadJSON("character")
		let morty: CharacterDTO = try loadJSON("character_2")
		await sut.saveCharacter(rick)
		await sut.saveCharacter(morty)

		// When
		let result = await sut.searchCharacters(
			page: 1,
			filter: CharacterFilterDTO(name: "Sanchez")
		)

		// Then
		#expect(result?.results.count == 1)
		#expect(result?.results.first?.id == 1)
	}

	@Test("Searches by status")
	func searchesByStatus() async {
		// Given
		let alive = makeCharacterDTO(id: 1, name: "Rick", status: "Alive")
		let dead = makeCharacterDTO(id: 2, name: "Zombie Rick", status: "Dead")
		await sut.saveCharacter(alive)
		await sut.saveCharacter(dead)

		// When
		let result = await sut.searchCharacters(
			page: 1,
			filter: CharacterFilterDTO(status: "alive")
		)

		// Then
		#expect(result?.results.count == 1)
		#expect(result?.results.first?.status == "Alive")
	}

	@Test("Searches by gender")
	func searchesByGender() async {
		// Given
		let male = makeCharacterDTO(id: 1, name: "Rick", gender: "Male")
		let female = makeCharacterDTO(id: 2, name: "Beth", gender: "Female")
		await sut.saveCharacter(male)
		await sut.saveCharacter(female)

		// When
		let result = await sut.searchCharacters(
			page: 1,
			filter: CharacterFilterDTO(gender: "female")
		)

		// Then
		#expect(result?.results.count == 1)
		#expect(result?.results.first?.gender == "Female")
	}

	@Test("Searches by species")
	func searchesBySpecies() async {
		// Given
		let human = makeCharacterDTO(id: 1, name: "Rick", species: "Human")
		let alien = makeCharacterDTO(id: 2, name: "Birdperson", species: "Bird-Person")
		await sut.saveCharacter(human)
		await sut.saveCharacter(alien)

		// When
		let result = await sut.searchCharacters(
			page: 1,
			filter: CharacterFilterDTO(species: "bird")
		)

		// Then
		#expect(result?.results.count == 1)
		#expect(result?.results.first?.species == "Bird-Person")
	}

	@Test("Searches by type")
	func searchesByType() async {
		// Given
		let normal = makeCharacterDTO(id: 1, name: "Rick")
		let parasite = makeCharacterDTO(id: 2, name: "Mr. Beauregard", type: "Parasite")
		await sut.saveCharacter(normal)
		await sut.saveCharacter(parasite)

		// When
		let result = await sut.searchCharacters(
			page: 1,
			filter: CharacterFilterDTO(type: "parasite")
		)

		// Then
		#expect(result?.results.count == 1)
		#expect(result?.results.first?.type == "Parasite")
	}

	@Test("Searches with multiple filters combined")
	func searchesWithMultipleFilters() async throws {
		// Given
		let rick: CharacterDTO = try loadJSON("character")
		let morty: CharacterDTO = try loadJSON("character_2")
		await sut.saveCharacter(rick)
		await sut.saveCharacter(morty)

		// When
		let result = await sut.searchCharacters(
			page: 1,
			filter: CharacterFilterDTO(name: "Rick", status: "alive", gender: "male")
		)

		// Then
		#expect(result?.results.count == 1)
		#expect(result?.results.first?.id == 1)
	}

	@Test("Search with empty filter returns all characters")
	func searchWithEmptyFilterReturnsAll() async throws {
		// Given
		let rick: CharacterDTO = try loadJSON("character")
		let morty: CharacterDTO = try loadJSON("character_2")
		await sut.saveCharacter(rick)
		await sut.saveCharacter(morty)

		// When
		let result = await sut.searchCharacters(
			page: 1,
			filter: .empty
		)

		// Then
		#expect(result?.results.count == 2)
	}

	// MARK: - Search Pagination

	@Test("Search returns correct pagination info")
	func searchReturnsPaginationInfo() async throws {
		// Given
		let rick: CharacterDTO = try loadJSON("character")
		await sut.saveCharacter(rick)

		// When
		let result = await sut.searchCharacters(
			page: 1,
			filter: CharacterFilterDTO(name: "Rick")
		)

		// Then
		#expect(result?.info.count == 1)
		#expect(result?.info.pages == 1)
		#expect(result?.info.next == nil)
		#expect(result?.info.prev == nil)
	}

	@Test("Search returns next and prev for multi-page results")
	func searchReturnsNextAndPrevForMultiPageResults() async {
		// Given — insert 21 characters to span 2 pages (pageSize = 20)
		for index in 1...21 {
			await sut.saveCharacter(makeCharacterDTO(id: index, name: "Character \(index)"))
		}

		// When — page 1
		let page1 = await sut.searchCharacters(page: 1, filter: .empty)

		// Then
		#expect(page1?.info.count == 21)
		#expect(page1?.info.pages == 2)
		#expect(page1?.info.next == "2")
		#expect(page1?.info.prev == nil)
		#expect(page1?.results.count == 20)

		// When — page 2
		let page2 = await sut.searchCharacters(page: 2, filter: .empty)

		// Then
		#expect(page2?.info.next == nil)
		#expect(page2?.info.prev == "1")
		#expect(page2?.results.count == 1)
	}

	@Test("Search returns nil for invalid page number")
	func searchReturnsNilForInvalidPage() async throws {
		// Given
		let rick: CharacterDTO = try loadJSON("character")
		await sut.saveCharacter(rick)

		// When
		let result = await sut.searchCharacters(
			page: 2,
			filter: CharacterFilterDTO(name: "Rick")
		)

		// Then
		#expect(result == nil)
	}

	@Test("Search returns nil for page zero")
	func searchReturnsNilForPageZero() async throws {
		// Given
		let rick: CharacterDTO = try loadJSON("character")
		await sut.saveCharacter(rick)

		// When
		let result = await sut.searchCharacters(
			page: 0,
			filter: .empty
		)

		// Then
		#expect(result == nil)
	}

	@Test("Search results are sorted by identifier")
	func searchResultsSortedByIdentifier() async throws {
		// Given
		let morty: CharacterDTO = try loadJSON("character_2")
		let rick: CharacterDTO = try loadJSON("character")
		await sut.saveCharacter(morty)
		await sut.saveCharacter(rick)

		// When
		let result = await sut.searchCharacters(
			page: 1,
			filter: .empty
		)

		// Then
		#expect(result?.results[0].id == 1)
		#expect(result?.results[1].id == 2)
	}
}

// MARK: - Private

private extension CharacterEntityDataSourceTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}

	func makeCharacterDTO(
		id: Int,
		name: String,
		status: String = "Alive",
		species: String = "Human",
		type: String = "",
		gender: String = "Male"
	) -> CharacterDTO {
		CharacterDTO(
			id: id,
			name: name,
			status: status,
			species: species,
			type: type,
			gender: gender,
			origin: LocationDTO(name: "Earth", url: ""),
			location: LocationDTO(name: "Earth", url: ""),
			image: "https://example.com/avatar/\(id).jpeg",
			episode: ["https://example.com/episode/1"],
			url: "https://example.com/character/\(id)",
			created: "2017-11-04T18:48:46.250Z"
		)
	}

	func makeResponseDTO(
		count: Int? = nil,
		pages: Int = 1,
		next: String? = nil,
		prev: String? = nil,
		characters: [CharacterDTO]
	) -> CharactersResponseDTO {
		CharactersResponseDTO(
			info: PaginationInfoDTO(
				count: count ?? characters.count,
				pages: pages,
				next: next,
				prev: prev
			),
			results: characters
		)
	}
}

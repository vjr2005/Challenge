import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharactersPageEntityDTOMapperTests {
	// MARK: - Properties

	private let sut = CharactersPageEntityDTOMapper()

	// MARK: - Pagination Info Mapping

	@Test("Maps pagination info from page entity to response DTO")
	func mapsPaginationInfo() {
		// Given
		let pageEntity = makePageEntity(
			page: 1,
			count: 826,
			pages: 42,
			next: "https://rickandmortyapi.com/api/character?page=2",
			prev: nil
		)

		// When
		let result = sut.map(pageEntity)

		// Then
		#expect(result.info.count == 826)
		#expect(result.info.pages == 42)
		#expect(result.info.next == "https://rickandmortyapi.com/api/character?page=2")
		#expect(result.info.prev == nil)
	}

	@Test("Maps pagination info with previous page")
	func mapsPaginationInfoWithPreviousPage() {
		// Given
		let pageEntity = makePageEntity(
			page: 2,
			count: 826,
			pages: 42,
			next: "3",
			prev: "1"
		)

		// When
		let result = sut.map(pageEntity)

		// Then
		#expect(result.info.next == "3")
		#expect(result.info.prev == "1")
	}

	// MARK: - Character Mapping

	@Test("Maps characters from page entity to response DTO")
	func mapsCharacters() {
		// Given
		let pageEntity = makePageEntity(characters: [makeCharacterEntity(identifier: 1, name: "Rick Sanchez")])

		// When
		let result = sut.map(pageEntity)

		// Then
		#expect(result.results.count == 1)
		#expect(result.results[0].id == 1)
		#expect(result.results[0].name == "Rick Sanchez")
	}

	@Test("Maps empty characters list")
	func mapsEmptyCharactersList() {
		// Given
		let pageEntity = makePageEntity(characters: [])

		// When
		let result = sut.map(pageEntity)

		// Then
		#expect(result.results.isEmpty)
	}

	// MARK: - Sorting

	@Test("Sorts characters by identifier in ascending order")
	func sortsCharactersByIdentifier() {
		// Given
		let pageEntity = makePageEntity(characters: [
			makeCharacterEntity(identifier: 3, name: "Summer Smith"),
			makeCharacterEntity(identifier: 1, name: "Rick Sanchez"),
			makeCharacterEntity(identifier: 2, name: "Morty Smith")
		])

		// When
		let result = sut.map(pageEntity)

		// Then
		#expect(result.results.count == 3)
		#expect(result.results[0].id == 1)
		#expect(result.results[1].id == 2)
		#expect(result.results[2].id == 3)
	}
}

// MARK: - Private

private extension CharactersPageEntityDTOMapperTests {
	func makeCharacterEntity(identifier: Int, name: String) -> CharacterEntity {
		CharacterEntity(
			identifier: identifier,
			name: name,
			status: "Alive",
			species: "Human",
			type: "",
			gender: "Male",
			origin: LocationEntity(name: "Earth", url: ""),
			location: LocationEntity(name: "Earth", url: ""),
			image: "https://example.com/avatar/\(identifier).jpeg",
			episode: ["https://example.com/episode/1"],
			url: "https://example.com/character/\(identifier)",
			created: "2017-11-04T18:48:46.250Z"
		)
	}

	func makePageEntity(
		page: Int = 1,
		count: Int = 1,
		pages: Int = 1,
		next: String? = nil,
		prev: String? = nil,
		characters: [CharacterEntity]? = nil
	) -> CharactersPageEntity {
		CharactersPageEntity(
			page: page,
			count: count,
			pages: pages,
			next: next,
			prev: prev,
			characters: characters ?? [makeCharacterEntity(identifier: 1, name: "Rick Sanchez")]
		)
	}
}

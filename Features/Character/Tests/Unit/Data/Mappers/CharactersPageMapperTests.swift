import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharactersPageMapperTests {
	// MARK: - Properties

	private let sut = CharactersPageMapper()

	// MARK: - Tests

	@Test("Maps full response DTO to domain model")
	func mapsFullResponse() throws {
		// Given
		let response: CharactersResponseDTO = try loadJSON("characters_response")
		let input = CharactersPageMapperInput(response: response, currentPage: 1)
		let expected = CharactersPage.stub()

		// When
		let result = sut.map(input)

		// Then
		#expect(result == expected)
	}

	@Test("Maps pagination info correctly")
	func mapsPaginationInfo() throws {
		// Given
		let response: CharactersResponseDTO = try loadJSON("characters_response_pagination")
		let input = CharactersPageMapperInput(response: response, currentPage: 1)

		// When
		let result = sut.map(input)

		// Then
		#expect(result.totalCount == 100)
		#expect(result.totalPages == 5)
		#expect(result.hasNextPage == true)
		#expect(result.hasPreviousPage == false)
	}

	@Test("Maps currentPage from input, not from DTO")
	func mapsCurrentPageFromInput() throws {
		// Given
		let response: CharactersResponseDTO = try loadJSON("characters_response")
		let input = CharactersPageMapperInput(response: response, currentPage: 7)

		// When
		let result = sut.map(input)

		// Then
		#expect(result.currentPage == 7)
	}

	@Test("Maps multiple characters in response")
	func mapsMultipleCharacters() throws {
		// Given
		let response: CharactersResponseDTO = try loadJSON("characters_response_two_results")
		let input = CharactersPageMapperInput(response: response, currentPage: 1)

		// When
		let result = sut.map(input)

		// Then
		#expect(result.characters.count == 2)
		#expect(result.characters[0].name == "Rick Sanchez")
		#expect(result.characters[1].name == "Morty Smith")
	}
}

// MARK: - Private

private extension CharactersPageMapperTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}
}

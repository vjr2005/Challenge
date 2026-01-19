import Foundation

@testable import ChallengeCharacter

actor CharacterMemoryDataSourceMock: CharacterMemoryDataSourceContract {
	private var characterStorage: [Int: CharacterDTO] = [:]
	private var pageStorage: [Int: CharactersResponseDTO] = [:]
	private(set) var saveCharacterCallCount = 0
	private(set) var savePageCallCount = 0

	// MARK: - Individual Characters

	func getCharacter(identifier: Int) -> CharacterDTO? {
		characterStorage[identifier]
	}

	func saveCharacter(_ character: CharacterDTO) {
		saveCharacterCallCount += 1
		characterStorage[character.id] = character
	}

	// MARK: - Paginated Results

	func getPage(_ page: Int) -> CharactersResponseDTO? {
		pageStorage[page]
	}

	func savePage(_ response: CharactersResponseDTO, page: Int) {
		savePageCallCount += 1
		pageStorage[page] = response
		for character in response.results {
			characterStorage[character.id] = character
		}
	}

	// MARK: - Test Helpers

	func getAllCharactersForTest() -> [CharacterDTO] {
		Array(characterStorage.values)
	}

	func setPageStorage(_ pages: [Int: CharactersResponseDTO]) {
		pageStorage = pages
	}
}

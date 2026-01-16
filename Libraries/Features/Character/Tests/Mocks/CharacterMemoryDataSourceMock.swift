import Foundation

@testable import ChallengeCharacter

actor CharacterMemoryDataSourceMock: CharacterMemoryDataSourceContract {
	private var characterStorage: [Int: CharacterDTO] = [:]
	private var pageStorage: [Int: CharactersResponseDTO] = [:]
	private(set) var saveCharacterCallCount = 0
	private(set) var savePageCallCount = 0
	private(set) var deleteCallCount = 0

	// MARK: - Individual Characters

	func getCharacter(identifier: Int) -> CharacterDTO? {
		characterStorage[identifier]
	}

	func getAllCharacters() -> [CharacterDTO] {
		Array(characterStorage.values)
	}

	func saveCharacter(_ character: CharacterDTO) {
		saveCharacterCallCount += 1
		characterStorage[character.id] = character
	}

	func saveCharacters(_ characters: [CharacterDTO]) {
		saveCharacterCallCount += 1
		for character in characters {
			characterStorage[character.id] = character
		}
	}

	func deleteCharacter(identifier: Int) {
		deleteCallCount += 1
		characterStorage.removeValue(forKey: identifier)
	}

	func deleteAllCharacters() {
		deleteCallCount += 1
		characterStorage.removeAll()
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

	func deletePage(_ page: Int) {
		deleteCallCount += 1
		pageStorage.removeValue(forKey: page)
	}

	func deleteAllPages() {
		deleteCallCount += 1
		pageStorage.removeAll()
	}

	// MARK: - Test Helpers

	func setCharacterStorage(_ characters: [CharacterDTO]) {
		characterStorage = Dictionary(uniqueKeysWithValues: characters.map { ($0.id, $0) })
	}

	func setPageStorage(_ pages: [Int: CharactersResponseDTO]) {
		pageStorage = pages
	}
}

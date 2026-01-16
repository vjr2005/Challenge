import Foundation

/// Contract for in-memory character data storage.
protocol CharacterMemoryDataSourceContract: Sendable {
	// MARK: - Individual Characters

	func getCharacter(identifier: Int) async -> CharacterDTO?
	func getAllCharacters() async -> [CharacterDTO]
	func saveCharacter(_ character: CharacterDTO) async
	func saveCharacters(_ characters: [CharacterDTO]) async
	func deleteCharacter(identifier: Int) async
	func deleteAllCharacters() async

	// MARK: - Paginated Results

	func getPage(_ page: Int) async -> CharactersResponseDTO?
	func savePage(_ response: CharactersResponseDTO, page: Int) async
	func deletePage(_ page: Int) async
	func deleteAllPages() async
}

/// Actor-based in-memory storage for character data.
/// Uses actor isolation to guarantee thread safety.
actor CharacterMemoryDataSource: CharacterMemoryDataSourceContract {
	private var characterStorage: [Int: CharacterDTO] = [:]
	private var pageStorage: [Int: CharactersResponseDTO] = [:]

	// MARK: - Individual Characters

	func getCharacter(identifier: Int) -> CharacterDTO? {
		characterStorage[identifier]
	}

	func getAllCharacters() -> [CharacterDTO] {
		Array(characterStorage.values)
	}

	func saveCharacter(_ character: CharacterDTO) {
		characterStorage[character.id] = character
	}

	func saveCharacters(_ characters: [CharacterDTO]) {
		for character in characters {
			characterStorage[character.id] = character
		}
	}

	func deleteCharacter(identifier: Int) {
		characterStorage.removeValue(forKey: identifier)
	}

	func deleteAllCharacters() {
		characterStorage.removeAll()
	}

	// MARK: - Paginated Results

	func getPage(_ page: Int) -> CharactersResponseDTO? {
		pageStorage[page]
	}

	func savePage(_ response: CharactersResponseDTO, page: Int) {
		pageStorage[page] = response
		// Also save individual characters for single lookups
		for character in response.results {
			characterStorage[character.id] = character
		}
	}

	func deletePage(_ page: Int) {
		pageStorage.removeValue(forKey: page)
	}

	func deleteAllPages() {
		pageStorage.removeAll()
	}
}

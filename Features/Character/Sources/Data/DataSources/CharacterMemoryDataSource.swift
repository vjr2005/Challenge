import Foundation

/// Contract for in-memory character data storage.
protocol CharacterMemoryDataSourceContract: Sendable {
	// MARK: - Individual Characters

	func getCharacter(identifier: Int) async -> CharacterDTO?
	func saveCharacter(_ character: CharacterDTO) async

	// MARK: - Paginated Results

	func getPage(_ page: Int) async -> CharactersResponseDTO?
	func savePage(_ response: CharactersResponseDTO, page: Int) async
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

	func saveCharacter(_ character: CharacterDTO) {
		characterStorage[character.id] = character
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
}

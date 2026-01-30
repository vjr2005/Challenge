import Foundation

protocol CharacterMemoryDataSourceContract: Sendable {
	// MARK: - Individual Characters

	func getCharacter(identifier: Int) async -> CharacterDTO?
	func saveCharacter(_ character: CharacterDTO) async

	// MARK: - Paginated Results

	func getPage(_ page: Int) async -> CharactersResponseDTO?
	func savePage(_ response: CharactersResponseDTO, page: Int) async

	// MARK: - Cache Management

	func clearPages() async
	func updateCharacterInPages(_ character: CharacterDTO) async
}

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
		for character in response.results {
			characterStorage[character.id] = character
		}
	}

	// MARK: - Cache Management

	func clearPages() {
		pageStorage.removeAll()
	}

	func updateCharacterInPages(_ character: CharacterDTO) {
		characterStorage[character.id] = character
		for (page, response) in pageStorage {
			let updatedResults = response.results.map { existing in
				existing.id == character.id ? character : existing
			}
			pageStorage[page] = CharactersResponseDTO(info: response.info, results: updatedResults)
		}
	}
}

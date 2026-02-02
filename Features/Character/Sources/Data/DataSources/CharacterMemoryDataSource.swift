import Foundation

protocol CharacterMemoryDataSourceContract: Sendable {
	// MARK: - Character Detail

	func getCharacterDetail(identifier: Int) async -> CharacterDTO?
	func saveCharacterDetail(_ character: CharacterDTO) async

	// MARK: - Paginated Results

	func getPage(_ page: Int) async -> CharactersResponseDTO?
	func savePage(_ response: CharactersResponseDTO, page: Int) async
}

actor CharacterMemoryDataSource: CharacterMemoryDataSourceContract {
	private var characterStorage: [Int: CharacterDTO] = [:]
	private var pageStorage: [Int: CharactersResponseDTO] = [:]

	// MARK: - Character Detail

	func getCharacterDetail(identifier: Int) -> CharacterDTO? {
		characterStorage[identifier]
	}

	func saveCharacterDetail(_ character: CharacterDTO) {
		characterStorage[character.id] = character
	}

	// MARK: - Paginated Results

	func getPage(_ page: Int) -> CharactersResponseDTO? {
		pageStorage[page]
	}

	func savePage(_ response: CharactersResponseDTO, page: Int) {
		pageStorage[page] = response
	}
}

actor CharacterMemoryDataSource: CharacterLocalDataSourceContract {
	private var characterStorage: [Int: CharacterDTO] = [:]
	private var pageStorage: [Int: CharactersResponseDTO] = [:]

	// MARK: - Character Detail

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
	}

	func clearPages() {
		pageStorage.removeAll()
	}
}

protocol CharacterLocalDataSourceContract: Actor {
	// MARK: - Character Detail

	func getCharacter(identifier: Int) async -> CharacterDTO?
	func saveCharacter(_ character: CharacterDTO) async

	// MARK: - Paginated Results

	func getPage(_ page: Int) async -> CharactersResponseDTO?
	func savePage(_ response: CharactersResponseDTO, page: Int) async
	func clearPages() async
}

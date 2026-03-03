protocol CharacterLocalDataSourceContract: Actor {
	// MARK: - Character Detail

	func getCharacter(identifier: Int) -> CharacterDTO?
	func saveCharacter(_ character: CharacterDTO)

	// MARK: - Paginated Results

	func getPage(_ page: Int) -> CharactersResponseDTO?
	func savePage(_ response: CharactersResponseDTO, page: Int)
	func clearPages()
}

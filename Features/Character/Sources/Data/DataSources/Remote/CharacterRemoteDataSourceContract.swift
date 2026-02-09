protocol CharacterRemoteDataSourceContract: Sendable {
	func fetchCharacter(identifier: Int) async throws -> CharacterDTO
	func fetchCharacters(page: Int, filter: CharacterFilter) async throws -> CharactersResponseDTO
}

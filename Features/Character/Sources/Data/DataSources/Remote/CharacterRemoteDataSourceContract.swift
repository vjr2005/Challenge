protocol CharacterRemoteDataSourceContract: Sendable {
	func fetchCharacter(identifier: Int) async throws -> CharacterDTO
	func fetchCharacters(page: Int, filter: CharacterFilterDTO) async throws -> CharactersResponseDTO
}

nonisolated protocol CharacterRemoteDataSourceContract: Sendable {
	@concurrent func fetchCharacter(identifier: Int) async throws -> CharacterDTO
	@concurrent func fetchCharacters(page: Int, filter: CharacterFilterDTO) async throws -> CharactersResponseDTO
}

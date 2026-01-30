import Foundation

protocol CharacterRepositoryContract: Sendable {
	func getCharacter(identifier: Int) async throws(CharacterError) -> Character
	func getCharacters(page: Int) async throws(CharacterError) -> CharactersPage
	func searchCharacters(page: Int, query: String) async throws(CharacterError) -> CharactersPage
	func refreshCharacter(identifier: Int) async throws(CharacterError) -> Character
	func clearPagesCache() async
}

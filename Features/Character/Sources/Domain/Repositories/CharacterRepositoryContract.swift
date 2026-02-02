import Foundation

protocol CharacterRepositoryContract: Sendable {
	func getCharacterDetail(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character
	func getCharacters(page: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> CharactersPage
	func searchCharacters(page: Int, query: String) async throws(CharacterError) -> CharactersPage
}

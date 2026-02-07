import ChallengeCore
import Foundation

protocol CharacterRepositoryContract: Sendable {
	func getCharacterDetail(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character
	func getCharacters(page: Int, cachePolicy: CachePolicy) async throws(CharactersPageError) -> CharactersPage
	func searchCharacters(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage
}

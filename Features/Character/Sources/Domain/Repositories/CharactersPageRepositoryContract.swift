import ChallengeCore
import Foundation

protocol CharactersPageRepositoryContract: Sendable {
	func getCharacters(page: Int, cachePolicy: CachePolicy) async throws(CharactersPageError) -> CharactersPage
	func searchCharacters(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage
}

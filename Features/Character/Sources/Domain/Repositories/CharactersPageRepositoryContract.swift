import ChallengeCore
import Foundation

protocol CharactersPageRepositoryContract: Sendable {
	func getCharactersPage(page: Int, cachePolicy: CachePolicy) async throws(CharactersPageError) -> CharactersPage
	func searchCharactersPage(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage
}

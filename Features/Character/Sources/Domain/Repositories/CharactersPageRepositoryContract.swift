import ChallengeCore
import Foundation

nonisolated protocol CharactersPageRepositoryContract: Sendable {
	@concurrent func getCharactersPage(page: Int, cachePolicy: CachePolicy) async throws(CharactersPageError) -> CharactersPage
	@concurrent func searchCharactersPage(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage
}

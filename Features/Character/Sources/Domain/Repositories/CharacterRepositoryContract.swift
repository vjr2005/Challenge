import Foundation

protocol CharacterRepositoryContract: Sendable {
	func getCharacter(identifier: Int) async throws(CharacterError) -> Character
	func getCharacters(page: Int) async throws(CharacterError) -> CharactersPage
}

import Foundation

protocol CharacterRepositoryContract: Sendable {
	func getCharacter(identifier: Int) async throws -> Character
	func getCharacters(page: Int) async throws -> CharactersPage
}

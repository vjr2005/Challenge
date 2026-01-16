import Foundation

/// Contract for accessing character data.
protocol CharacterRepositoryContract: Sendable {
	func getCharacter(identifier: Int) async throws -> Character
	func getCharacters(page: Int) async throws -> CharactersPage
}

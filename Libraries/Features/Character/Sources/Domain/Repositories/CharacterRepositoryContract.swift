import Foundation

/// Contract for accessing character data.
protocol CharacterRepositoryContract: Sendable {
	func getCharacter(id: Int) async throws -> Character
}

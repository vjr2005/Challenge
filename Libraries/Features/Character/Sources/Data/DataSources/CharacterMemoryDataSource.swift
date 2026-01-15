import Foundation

/// Contract for in-memory character data storage.
protocol CharacterMemoryDataSourceContract: Sendable {
	func getCharacter(id: Int) async -> CharacterDTO?
	func getAllCharacters() async -> [CharacterDTO]
	func saveCharacter(_ character: CharacterDTO) async
	func saveCharacters(_ characters: [CharacterDTO]) async
	func deleteCharacter(id: Int) async
	func deleteAllCharacters() async
}

/// Actor-based in-memory storage for character data.
/// Uses actor isolation to guarantee thread safety.
actor CharacterMemoryDataSource: CharacterMemoryDataSourceContract {
	private var storage: [Int: CharacterDTO] = [:]

	func getCharacter(id: Int) -> CharacterDTO? {
		storage[id]
	}

	func getAllCharacters() -> [CharacterDTO] {
		Array(storage.values)
	}

	func saveCharacter(_ character: CharacterDTO) {
		storage[character.id] = character
	}

	func saveCharacters(_ characters: [CharacterDTO]) {
		for character in characters {
			storage[character.id] = character
		}
	}

	func deleteCharacter(id: Int) {
		storage.removeValue(forKey: id)
	}

	func deleteAllCharacters() {
		storage.removeAll()
	}
}

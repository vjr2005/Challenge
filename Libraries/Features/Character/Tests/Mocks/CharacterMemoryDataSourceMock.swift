import Foundation

@testable import ChallengeCharacter

actor CharacterMemoryDataSourceMock: CharacterMemoryDataSourceContract {
	private var storage: [Int: CharacterDTO] = [:]
	private(set) var saveCallCount = 0
	private(set) var deleteCallCount = 0

	func getCharacter(identifier: Int) -> CharacterDTO? {
		storage[identifier]
	}

	func getAllCharacters() -> [CharacterDTO] {
		Array(storage.values)
	}

	func saveCharacter(_ character: CharacterDTO) {
		saveCallCount += 1
		storage[character.id] = character
	}

	func saveCharacters(_ characters: [CharacterDTO]) {
		saveCallCount += 1
		for character in characters {
			storage[character.id] = character
		}
	}

	func deleteCharacter(identifier: Int) {
		deleteCallCount += 1
		storage.removeValue(forKey: identifier)
	}

	func deleteAllCharacters() {
		deleteCallCount += 1
		storage.removeAll()
	}

	// MARK: - Test Helpers

	func setStorage(_ characters: [CharacterDTO]) {
		storage = Dictionary(uniqueKeysWithValues: characters.map { ($0.id, $0) })
	}
}

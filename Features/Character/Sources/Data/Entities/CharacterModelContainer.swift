import Foundation
import SwiftData

enum CharacterModelContainer {
	private static let schema = Schema([
		CharacterEntity.self,
		CharactersPageEntity.self
	])

	static func create(inMemoryOnly: Bool = false) -> ModelContainer {
		do {
			let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemoryOnly)
			return try ModelContainer(for: schema, configurations: [configuration])
		} catch {
			fatalError("Failed to create CharacterModelContainer: \(error)")
		}
	}
}

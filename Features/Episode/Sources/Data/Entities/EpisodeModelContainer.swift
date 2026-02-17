import Foundation
import SwiftData

enum EpisodeModelContainer {
	private static let schema = Schema([
		EpisodeCharacterWithEpisodesEntity.self,
		EpisodeEntity.self,
		EpisodeCharacterEntity.self
	])

	static func create(inMemoryOnly: Bool = false) -> ModelContainer {
		do {
			let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemoryOnly)
			return try ModelContainer(for: schema, configurations: [configuration])
		} catch {
			fatalError("Failed to create EpisodeModelContainer: \(error)")
		}
	}
}

import Foundation
import SwiftData

@ModelActor
actor EpisodeEntityDataSource: EpisodeLocalDataSourceContract {
	private let entityMapper = EpisodeCharacterWithEpisodesEntityMapper()
	private let entityDTOMapper = EpisodeCharacterWithEpisodesEntityDTOMapper()

	// MARK: - EpisodeLocalDataSourceContract

	func getEpisodes(characterIdentifier: Int) -> EpisodeCharacterWithEpisodesDTO? {
		let descriptor = FetchDescriptor<EpisodeCharacterWithEpisodesEntity>(
			predicate: #Predicate { $0.identifier == characterIdentifier }
		)
		guard let entity = try? modelContext.fetch(descriptor).first else { return nil }
		return entityDTOMapper.map(entity)
	}

	func saveEpisodes(_ episodes: EpisodeCharacterWithEpisodesDTO, characterIdentifier: Int) {
		let deleteDescriptor = FetchDescriptor<EpisodeCharacterWithEpisodesEntity>(
			predicate: #Predicate { $0.identifier == characterIdentifier }
		)
		if let existing = try? modelContext.fetch(deleteDescriptor).first {
			modelContext.delete(existing)
		}

		let entity = entityMapper.map(episodes)
		modelContext.insert(entity)
		try? modelContext.save()
	}
}

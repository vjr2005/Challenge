import Foundation

protocol RefreshCharacterEpisodesUseCaseContract: Sendable {
	func execute(characterIdentifier: Int) async throws(EpisodeError) -> EpisodeCharacterWithEpisodes
}

struct RefreshCharacterEpisodesUseCase: RefreshCharacterEpisodesUseCaseContract {
	private let repository: any EpisodeRepositoryContract

	init(repository: any EpisodeRepositoryContract) {
		self.repository = repository
	}

	func execute(characterIdentifier: Int) async throws(EpisodeError) -> EpisodeCharacterWithEpisodes {
		try await repository.getEpisodes(characterIdentifier: characterIdentifier, cachePolicy: .remoteFirst)
	}
}

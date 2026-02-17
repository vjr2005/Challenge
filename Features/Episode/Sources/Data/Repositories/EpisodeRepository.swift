import ChallengeCore
import Foundation

struct EpisodeRepository: EpisodeRepositoryContract {
	private let remoteDataSource: EpisodeRemoteDataSourceContract
	private let volatileDataSource: EpisodeLocalDataSourceContract
	private let persistenceDataSource: EpisodeLocalDataSourceContract
	private let mapper = EpisodeCharacterWithEpisodesMapper()
	private let errorMapper = EpisodeErrorMapper()
	private let cacheExecutor = CachePolicyExecutor()

	init(
		remoteDataSource: EpisodeRemoteDataSourceContract,
		volatile: EpisodeLocalDataSourceContract,
		persistence: EpisodeLocalDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.volatileDataSource = volatile
		self.persistenceDataSource = persistence
	}

	func getEpisodes(characterIdentifier: Int, cachePolicy: CachePolicy) async throws(EpisodeError) -> EpisodeCharacterWithEpisodes {
		try await cacheExecutor.execute(
			policy: cachePolicy,
			fetchFromRemote: { try await remoteDataSource.fetchEpisodes(characterIdentifier: characterIdentifier) },
			getFromVolatile: { await volatileDataSource.getEpisodes(characterIdentifier: characterIdentifier) },
			getFromPersistence: { await persistenceDataSource.getEpisodes(characterIdentifier: characterIdentifier) },
			saveToVolatile: { await volatileDataSource.saveEpisodes($0, characterIdentifier: characterIdentifier) },
			saveToPersistence: { await persistenceDataSource.saveEpisodes($0, characterIdentifier: characterIdentifier) },
			mapper: { mapper.map($0) },
			errorMapper: { errorMapper.map(EpisodeErrorMapperInput(error: $0, characterIdentifier: characterIdentifier)) }
		)
	}
}

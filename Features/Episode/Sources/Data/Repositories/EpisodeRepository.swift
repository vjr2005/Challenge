import ChallengeCore
import Foundation

nonisolated struct EpisodeRepository: EpisodeRepositoryContract {
	private let remoteDataSource: any EpisodeRemoteDataSourceContract
	private let memoryDataSource: any EpisodeLocalDataSourceContract
	private let mapper = EpisodeCharacterWithEpisodesMapper()
	private let errorMapper = EpisodeErrorMapper()
	private let cacheExecutor = CachePolicyExecutor()

	init(
		remoteDataSource: any EpisodeRemoteDataSourceContract,
		memoryDataSource: any EpisodeLocalDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.memoryDataSource = memoryDataSource
	}

	@concurrent func getEpisodes(characterIdentifier: Int, cachePolicy: CachePolicy) async throws(EpisodeError) -> EpisodeCharacterWithEpisodes {
		try await cacheExecutor.execute(
			policy: cachePolicy,
			fetchFromRemote: { try await remoteDataSource.fetchEpisodes(characterIdentifier: characterIdentifier) },
			getFromCache: { await memoryDataSource.getEpisodes(characterIdentifier: characterIdentifier) },
			saveToCache: { await memoryDataSource.saveEpisodes($0, characterIdentifier: characterIdentifier) },
			mapper: { mapper.map($0) },
			errorMapper: { errorMapper.map(EpisodeErrorMapperInput(error: $0, characterIdentifier: characterIdentifier)) }
		)
	}
}

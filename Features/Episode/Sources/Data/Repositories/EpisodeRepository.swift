import ChallengeCore
import Foundation

struct EpisodeRepository: EpisodeRepositoryContract {
	private let remoteDataSource: EpisodeRemoteDataSourceContract
	private let memoryDataSource: EpisodeLocalDataSourceContract
	private let mapper = EpisodeCharacterWithEpisodesMapper()
	private let errorMapper = EpisodeErrorMapper()
	private let cacheExecutor = CachePolicyExecutor()

	init(
		remoteDataSource: EpisodeRemoteDataSourceContract,
		memoryDataSource: EpisodeLocalDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.memoryDataSource = memoryDataSource
	}

	func getEpisodes(characterIdentifier: Int, cachePolicy: CachePolicy) async throws(EpisodeError) -> EpisodeCharacterWithEpisodes {
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

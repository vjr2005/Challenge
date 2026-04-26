import ChallengeCore
import Foundation

nonisolated struct EpisodeRepository: EpisodeRepositoryContract {
	private let remoteDataSource: any EpisodeRemoteDataSourceContract
	private let memoryDataSource: any EpisodeLocalDataSourceContract
	private let mapper = EpisodeCharacterWithEpisodesMapper()
	private let errorMapper = EpisodeErrorMapper()

	init(
		remoteDataSource: any EpisodeRemoteDataSourceContract,
		memoryDataSource: any EpisodeLocalDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.memoryDataSource = memoryDataSource
	}

	@concurrent func getEpisodes(characterIdentifier: Int, cachePolicy: CachePolicy) async throws(EpisodeError) -> EpisodeCharacterWithEpisodes {
		do {
			let dto = try await cachePolicy.fetch(
				fromRemote: { try await remoteDataSource.fetchEpisodes(characterIdentifier: characterIdentifier) },
				fromCache: { await memoryDataSource.getEpisodes(characterIdentifier: characterIdentifier) },
				saveToCache: { await memoryDataSource.saveEpisodes($0, characterIdentifier: characterIdentifier) }
			)
			return mapper.map(dto)
		} catch {
			throw errorMapper.map(EpisodeErrorMapperInput(error: error, characterIdentifier: characterIdentifier))
		}
	}
}

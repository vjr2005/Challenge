import ChallengeCore
import Foundation

struct EpisodeRepository: EpisodeRepositoryContract {
	private let remoteDataSource: EpisodeRemoteDataSourceContract
	private let memoryDataSource: EpisodeLocalDataSourceContract
	private let mapper = EpisodeCharacterWithEpisodesMapper()
	private let errorMapper = EpisodeErrorMapper()

	init(
		remoteDataSource: EpisodeRemoteDataSourceContract,
		memoryDataSource: EpisodeLocalDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.memoryDataSource = memoryDataSource
	}

	func getEpisodes(characterIdentifier: Int, cachePolicy: CachePolicy) async throws(EpisodeError) -> EpisodeCharacterWithEpisodes {
		switch cachePolicy {
		case .localFirst:
			try await getEpisodesLocalFirst(characterIdentifier: characterIdentifier)
		case .remoteFirst:
			try await getEpisodesRemoteFirst(characterIdentifier: characterIdentifier)
		case .noCache:
			try await getEpisodesNoCache(characterIdentifier: characterIdentifier)
		}
	}
}

// MARK: - Remote Fetch

private extension EpisodeRepository {
	func fetchFromRemote(characterIdentifier: Int) async throws(EpisodeError) -> EpisodeCharacterWithEpisodesDTO {
		do {
			return try await remoteDataSource.fetchEpisodes(characterIdentifier: characterIdentifier)
		} catch {
			throw errorMapper.map(EpisodeErrorMapperInput(error: error, characterIdentifier: characterIdentifier))
		}
	}
}

// MARK: - Cache Strategies

private extension EpisodeRepository {
	func getEpisodesLocalFirst(characterIdentifier: Int) async throws(EpisodeError) -> EpisodeCharacterWithEpisodes {
		if let cached = await memoryDataSource.getEpisodes(characterIdentifier: characterIdentifier) {
			return mapper.map(cached)
		}
		let dto = try await fetchFromRemote(characterIdentifier: characterIdentifier)
		await memoryDataSource.saveEpisodes(dto, characterIdentifier: characterIdentifier)
		return mapper.map(dto)
	}

	func getEpisodesRemoteFirst(characterIdentifier: Int) async throws(EpisodeError) -> EpisodeCharacterWithEpisodes {
		do {
			let dto = try await fetchFromRemote(characterIdentifier: characterIdentifier)
			await memoryDataSource.saveEpisodes(dto, characterIdentifier: characterIdentifier)
			return mapper.map(dto)
		} catch {
			if let cached = await memoryDataSource.getEpisodes(characterIdentifier: characterIdentifier) {
				return mapper.map(cached)
			}
			throw error
		}
	}

	func getEpisodesNoCache(characterIdentifier: Int) async throws(EpisodeError) -> EpisodeCharacterWithEpisodes {
		let dto = try await fetchFromRemote(characterIdentifier: characterIdentifier)
		return mapper.map(dto)
	}
}

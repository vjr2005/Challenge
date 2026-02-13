import ChallengeCore
import Foundation

struct CharacterRepository: CharacterRepositoryContract {
	private let remoteDataSource: CharacterRemoteDataSourceContract
	private let memoryDataSource: CharacterLocalDataSourceContract
	private let mapper = CharacterMapper()
	private let errorMapper = CharacterErrorMapper()
	private let cacheExecutor = CachePolicyExecutor()

	init(
		remoteDataSource: CharacterRemoteDataSourceContract,
		memoryDataSource: CharacterLocalDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.memoryDataSource = memoryDataSource
	}

	func getCharacter(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character {
		try await cacheExecutor.execute(
			policy: cachePolicy,
			fetchFromRemote: { try await remoteDataSource.fetchCharacter(identifier: identifier) },
			getFromCache: { await memoryDataSource.getCharacter(identifier: identifier) },
			saveToCache: { await memoryDataSource.saveCharacter($0) },
			mapper: { mapper.map($0) },
			errorMapper: { errorMapper.map(CharacterErrorMapperInput(error: $0, identifier: identifier)) }
		)
	}
}

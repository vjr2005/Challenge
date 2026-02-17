import ChallengeCore
import Foundation

struct CharacterRepository: CharacterRepositoryContract {
	private let remoteDataSource: CharacterRemoteDataSourceContract
	private let volatileDataSource: CharacterLocalDataSourceContract
	private let persistenceDataSource: CharacterLocalDataSourceContract
	private let mapper = CharacterMapper()
	private let errorMapper = CharacterErrorMapper()
	private let cacheExecutor = CachePolicyExecutor()

	init(
		remoteDataSource: CharacterRemoteDataSourceContract,
		volatile: CharacterLocalDataSourceContract,
		persistence: CharacterLocalDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.volatileDataSource = volatile
		self.persistenceDataSource = persistence
	}

	func getCharacter(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character {
		try await cacheExecutor.execute(
			policy: cachePolicy,
			fetchFromRemote: { try await remoteDataSource.fetchCharacter(identifier: identifier) },
			getFromVolatile: { await volatileDataSource.getCharacter(identifier: identifier) },
			getFromPersistence: { await persistenceDataSource.getCharacter(identifier: identifier) },
			saveToVolatile: { await volatileDataSource.saveCharacter($0) },
			saveToPersistence: { await persistenceDataSource.saveCharacter($0) },
			mapper: { mapper.map($0) },
			errorMapper: { errorMapper.map(CharacterErrorMapperInput(error: $0, identifier: identifier)) }
		)
	}
}

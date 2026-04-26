import ChallengeCore
import Foundation

nonisolated struct CharacterRepository: CharacterRepositoryContract {
	private let remoteDataSource: any CharacterRemoteDataSourceContract
	private let memoryDataSource: any CharacterLocalDataSourceContract
	private let mapper = CharacterMapper()
	private let errorMapper = CharacterErrorMapper()

	init(
		remoteDataSource: any CharacterRemoteDataSourceContract,
		memoryDataSource: any CharacterLocalDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.memoryDataSource = memoryDataSource
	}

	@concurrent func getCharacter(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character {
		do {
			let dto = try await cachePolicy.fetch(
				fromRemote: { try await remoteDataSource.fetchCharacter(identifier: identifier) },
				fromCache: { await memoryDataSource.getCharacter(identifier: identifier) },
				saveToCache: { await memoryDataSource.saveCharacter($0) }
			)
			return mapper.map(dto)
		} catch {
			throw errorMapper.map(CharacterErrorMapperInput(error: error, identifier: identifier))
		}
	}
}

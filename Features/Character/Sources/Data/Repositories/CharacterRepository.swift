import ChallengeCore
import Foundation

struct CharacterRepository: CharacterRepositoryContract {
	private let remoteDataSource: CharacterRemoteDataSourceContract
	private let memoryDataSource: CharacterLocalDataSourceContract
	private let mapper = CharacterMapper()
	private let errorMapper = CharacterErrorMapper()

	init(
		remoteDataSource: CharacterRemoteDataSourceContract,
		memoryDataSource: CharacterLocalDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.memoryDataSource = memoryDataSource
	}

	func getCharacter(identifier: Int, cachePolicy: CachePolicy) async throws(CharacterError) -> Character {
		switch cachePolicy {
		case .localFirst:
			try await getCharacterLocalFirst(identifier: identifier)
		case .remoteFirst:
			try await getCharacterRemoteFirst(identifier: identifier)
		case .noCache:
			try await getCharacterNoCache(identifier: identifier)
		}
	}
}

// MARK: - Remote Fetch

private extension CharacterRepository {
	func fetchFromRemote(identifier: Int) async throws(CharacterError) -> CharacterDTO {
		do {
			return try await remoteDataSource.fetchCharacter(identifier: identifier)
		} catch {
			throw errorMapper.map(CharacterErrorMapperInput(error: error, identifier: identifier))
		}
	}
}

// MARK: - Cache Strategies

private extension CharacterRepository {
	func getCharacterLocalFirst(identifier: Int) async throws(CharacterError) -> Character {
		if let cached = await memoryDataSource.getCharacter(identifier: identifier) {
			return mapper.map(cached)
		}
		let dto = try await fetchFromRemote(identifier: identifier)
		await memoryDataSource.saveCharacter(dto)
		return mapper.map(dto)
	}

	func getCharacterRemoteFirst(identifier: Int) async throws(CharacterError) -> Character {
		do {
			let dto = try await fetchFromRemote(identifier: identifier)
			await memoryDataSource.saveCharacter(dto)
			return mapper.map(dto)
		} catch {
			if let cached = await memoryDataSource.getCharacter(identifier: identifier) {
				return mapper.map(cached)
			}
			throw error
		}
	}

	func getCharacterNoCache(identifier: Int) async throws(CharacterError) -> Character {
		let dto = try await fetchFromRemote(identifier: identifier)
		return mapper.map(dto)
	}
}

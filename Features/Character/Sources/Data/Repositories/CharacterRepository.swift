import ChallengeCore
import ChallengeNetworking
import Foundation

struct CharacterRepository: CharacterRepositoryContract {
	private let remoteDataSource: CharacterRemoteDataSourceContract
	private let memoryDataSource: CharacterMemoryDataSourceContract

	init(
		remoteDataSource: CharacterRemoteDataSourceContract,
		memoryDataSource: CharacterMemoryDataSourceContract
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
		} catch let error as HTTPError {
			throw mapHTTPError(error, identifier: identifier)
		} catch {
			throw .loadFailed
		}
	}
}

// MARK: - Cache Strategies

private extension CharacterRepository {
	func getCharacterLocalFirst(identifier: Int) async throws(CharacterError) -> Character {
		if let cached = await memoryDataSource.getCharacter(identifier: identifier) {
			return cached.toDomain()
		}
		let dto = try await fetchFromRemote(identifier: identifier)
		await memoryDataSource.saveCharacter(dto)
		return dto.toDomain()
	}

	func getCharacterRemoteFirst(identifier: Int) async throws(CharacterError) -> Character {
		do {
			let dto = try await fetchFromRemote(identifier: identifier)
			await memoryDataSource.saveCharacter(dto)
			return dto.toDomain()
		} catch {
			if let cached = await memoryDataSource.getCharacter(identifier: identifier) {
				return cached.toDomain()
			}
			throw error
		}
	}

	func getCharacterNoCache(identifier: Int) async throws(CharacterError) -> Character {
		let dto = try await fetchFromRemote(identifier: identifier)
		return dto.toDomain()
	}
}

// MARK: - Error Mapping

private extension CharacterRepository {
	func mapHTTPError(_ error: HTTPError, identifier: Int) -> CharacterError {
		switch error {
		case .statusCode(404, _):
			.notFound(identifier: identifier)
		case .invalidURL, .invalidResponse, .statusCode:
			.loadFailed
		}
	}
}

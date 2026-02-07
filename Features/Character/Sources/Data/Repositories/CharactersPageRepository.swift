import ChallengeCore
import ChallengeNetworking
import Foundation

struct CharactersPageRepository: CharactersPageRepositoryContract {
	private let remoteDataSource: CharacterRemoteDataSourceContract
	private let memoryDataSource: CharacterMemoryDataSourceContract

	init(
		remoteDataSource: CharacterRemoteDataSourceContract,
		memoryDataSource: CharacterMemoryDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.memoryDataSource = memoryDataSource
	}

	func getCharacters(page: Int, cachePolicy: CachePolicy) async throws(CharactersPageError) -> CharactersPage {
		switch cachePolicy {
		case .localFirst:
			try await getCharactersLocalFirst(page: page)
		case .remoteFirst:
			try await getCharactersRemoteFirst(page: page)
		case .noCache:
			try await getCharactersNoCache(page: page)
		}
	}

	func searchCharacters(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage {
		do {
			let response = try await remoteDataSource.fetchCharacters(page: page, filter: filter)
			return response.toDomain(currentPage: page)
		} catch let error as HTTPError {
			if case .statusCode(404, _) = error {
				return CharactersPage(
					characters: [],
					currentPage: page,
					totalPages: 0,
					totalCount: 0,
					hasNextPage: false,
					hasPreviousPage: false
				)
			}
			throw mapHTTPError(error, page: page)
		} catch {
			throw .loadFailed
		}
	}
}

// MARK: - Remote Fetch

private extension CharactersPageRepository {
	func fetchFromRemote(page: Int) async throws(CharactersPageError) -> CharactersResponseDTO {
		do {
			return try await remoteDataSource.fetchCharacters(page: page, filter: .empty)
		} catch let error as HTTPError {
			throw mapHTTPError(error, page: page)
		} catch {
			throw .loadFailed
		}
	}
}

// MARK: - Cache Strategies

private extension CharactersPageRepository {
	func getCharactersLocalFirst(page: Int) async throws(CharactersPageError) -> CharactersPage {
		if let cached = await memoryDataSource.getPage(page) {
			return cached.toDomain(currentPage: page)
		}
		let response = try await fetchFromRemote(page: page)
		await memoryDataSource.savePage(response, page: page)
		return response.toDomain(currentPage: page)
	}

	func getCharactersRemoteFirst(page: Int) async throws(CharactersPageError) -> CharactersPage {
		do {
			let response = try await fetchFromRemote(page: page)
			await memoryDataSource.savePage(response, page: page)
			return response.toDomain(currentPage: page)
		} catch {
			if let cached = await memoryDataSource.getPage(page) {
				return cached.toDomain(currentPage: page)
			}
			throw error
		}
	}

	func getCharactersNoCache(page: Int) async throws(CharactersPageError) -> CharactersPage {
		let response = try await fetchFromRemote(page: page)
		return response.toDomain(currentPage: page)
	}
}

// MARK: - Error Mapping

private extension CharactersPageRepository {
	func mapHTTPError(_ error: HTTPError, page: Int) -> CharactersPageError {
		switch error {
		case .statusCode(404, _):
			.invalidPage(page: page)
		case .invalidURL, .invalidResponse, .statusCode:
			.loadFailed
		}
	}
}

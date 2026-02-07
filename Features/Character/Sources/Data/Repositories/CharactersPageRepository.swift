import ChallengeCore
import ChallengeNetworking
import Foundation

struct CharactersPageRepository: CharactersPageRepositoryContract {
	private let remoteDataSource: CharacterRemoteDataSourceContract
	private let memoryDataSource: CharacterMemoryDataSourceContract
	private let mapper = CharactersPageMapper()

	init(
		remoteDataSource: CharacterRemoteDataSourceContract,
		memoryDataSource: CharacterMemoryDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.memoryDataSource = memoryDataSource
	}

	func getCharactersPage(page: Int, cachePolicy: CachePolicy) async throws(CharactersPageError) -> CharactersPage {
		switch cachePolicy {
		case .localFirst:
			try await getCharactersPageLocalFirst(page: page)
		case .remoteFirst:
			try await getCharactersPageRemoteFirst(page: page)
		case .noCache:
			try await getCharactersPageNoCache(page: page)
		}
	}

	func searchCharactersPage(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage {
		do {
			let response = try await remoteDataSource.fetchCharacters(page: page, filter: filter)
			return mapper.map(CharactersPageMapperInput(response: response, currentPage: page))
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
	func getCharactersPageLocalFirst(page: Int) async throws(CharactersPageError) -> CharactersPage {
		if let cached = await memoryDataSource.getPage(page) {
			return mapper.map(CharactersPageMapperInput(response: cached, currentPage: page))
		}
		let response = try await fetchFromRemote(page: page)
		await memoryDataSource.savePage(response, page: page)
		return mapper.map(CharactersPageMapperInput(response: response, currentPage: page))
	}

	func getCharactersPageRemoteFirst(page: Int) async throws(CharactersPageError) -> CharactersPage {
		do {
			let response = try await fetchFromRemote(page: page)
			await memoryDataSource.savePage(response, page: page)
			return mapper.map(CharactersPageMapperInput(response: response, currentPage: page))
		} catch {
			if let cached = await memoryDataSource.getPage(page) {
				return mapper.map(CharactersPageMapperInput(response: cached, currentPage: page))
			}
			throw error
		}
	}

	func getCharactersPageNoCache(page: Int) async throws(CharactersPageError) -> CharactersPage {
		let response = try await fetchFromRemote(page: page)
		return mapper.map(CharactersPageMapperInput(response: response, currentPage: page))
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

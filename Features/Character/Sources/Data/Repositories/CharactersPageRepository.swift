import ChallengeCore
import Foundation

struct CharactersPageRepository: CharactersPageRepositoryContract {
	private let remoteDataSource: CharacterRemoteDataSourceContract
	private let memoryDataSource: CharacterLocalDataSourceContract
	private let mapper = CharactersPageMapper()
	private let errorMapper = CharactersPageErrorMapper()

	init(
		remoteDataSource: CharacterRemoteDataSourceContract,
		memoryDataSource: CharacterLocalDataSourceContract
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
		} catch {
			let mappedError = errorMapper.map(CharactersPageErrorMapperInput(error: error, page: page))
			if case .invalidPage = mappedError {
				return CharactersPage(
					characters: [],
					currentPage: page,
					totalPages: 0,
					totalCount: 0,
					hasNextPage: false,
					hasPreviousPage: false
				)
			}
			throw mappedError
		}
	}
}

// MARK: - Remote Fetch

private extension CharactersPageRepository {
	func fetchFromRemote(page: Int) async throws(CharactersPageError) -> CharactersResponseDTO {
		do {
			return try await remoteDataSource.fetchCharacters(page: page, filter: .empty)
		} catch {
			throw errorMapper.map(CharactersPageErrorMapperInput(error: error, page: page))
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

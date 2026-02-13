import ChallengeCore
import Foundation

struct CharactersPageRepository: CharactersPageRepositoryContract {
	private let remoteDataSource: CharacterRemoteDataSourceContract
	private let memoryDataSource: CharacterLocalDataSourceContract
	private let mapper = CharactersPageMapper()
	private let filterMapper = CharacterFilterMapper()
	private let errorMapper = CharactersPageErrorMapper()
	private let cacheExecutor = CachePolicyExecutor()

	init(
		remoteDataSource: CharacterRemoteDataSourceContract,
		memoryDataSource: CharacterLocalDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.memoryDataSource = memoryDataSource
	}

	func getCharactersPage(page: Int, cachePolicy: CachePolicy) async throws(CharactersPageError) -> CharactersPage {
		try await cacheExecutor.execute(
			policy: cachePolicy,
			fetchFromRemote: { try await remoteDataSource.fetchCharacters(page: page, filter: .empty) },
			getFromCache: { await memoryDataSource.getPage(page) },
			saveToCache: { await memoryDataSource.savePage($0, page: page) },
			mapper: { mapper.map(CharactersPageMapperInput(response: $0, currentPage: page)) },
			errorMapper: { errorMapper.map(CharactersPageErrorMapperInput(error: $0, page: page)) }
		)
	}

	func searchCharactersPage(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage {
		do {
			let filterDTO = filterMapper.map(filter)
			let response = try await remoteDataSource.fetchCharacters(page: page, filter: filterDTO)
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

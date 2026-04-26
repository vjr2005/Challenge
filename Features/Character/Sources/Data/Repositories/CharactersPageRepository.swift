import ChallengeCore
import Foundation

nonisolated struct CharactersPageRepository: CharactersPageRepositoryContract {
	private let remoteDataSource: any CharacterRemoteDataSourceContract
	private let memoryDataSource: any CharacterLocalDataSourceContract
	private let mapper = CharactersPageMapper()
	private let filterMapper = CharacterFilterMapper()
	private let errorMapper = CharactersPageErrorMapper()

	init(
		remoteDataSource: any CharacterRemoteDataSourceContract,
		memoryDataSource: any CharacterLocalDataSourceContract
	) {
		self.remoteDataSource = remoteDataSource
		self.memoryDataSource = memoryDataSource
	}

	@concurrent func getCharactersPage(page: Int, cachePolicy: CachePolicy) async throws(CharactersPageError) -> CharactersPage {
		do {
			let dto = try await cachePolicy.fetch(
				fromRemote: { try await remoteDataSource.fetchCharacters(page: page, filter: .empty) },
				fromCache: { await memoryDataSource.getPage(page) },
				saveToCache: { await memoryDataSource.savePage($0, page: page) }
			)
			return mapper.map(CharactersPageMapperInput(response: dto, currentPage: page))
		} catch {
			throw errorMapper.map(CharactersPageErrorMapperInput(error: error, page: page))
		}
	}

	@concurrent func clearPagesCache() async {
		await memoryDataSource.clearPages()
	}

	@concurrent func searchCharactersPage(page: Int, filter: CharacterFilter) async throws(CharactersPageError) -> CharactersPage {
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

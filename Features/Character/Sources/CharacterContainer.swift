import ChallengeCore
import ChallengeNetworking

public final class CharacterContainer: Sendable {
    // MARK: - Dependencies

    private let httpClient: any HTTPClientContract
    private let memoryDataSource = CharacterMemoryDataSource()

    // MARK: - Init

    public init(httpClient: any HTTPClientContract) {
        self.httpClient = httpClient
    }

    // MARK: - Repository

    private var repository: any CharacterRepositoryContract {
        CharacterRepository(
            remoteDataSource: CharacterRemoteDataSource(httpClient: httpClient),
            memoryDataSource: memoryDataSource
        )
    }

    // MARK: - Factories

    func makeCharacterListViewModel(router: any RouterContract) -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: repository),
            navigator: CharacterListNavigator(router: router)
        )
    }

    func makeCharacterDetailViewModel(
        identifier: Int,
        router: any RouterContract
    ) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: GetCharacterUseCase(repository: repository),
            navigator: CharacterDetailNavigator(router: router)
        )
    }
}

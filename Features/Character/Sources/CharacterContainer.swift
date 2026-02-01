import ChallengeCore
import ChallengeNetworking

/// Dependency container for the Character feature.
public final class CharacterContainer: Sendable {
    // MARK: - Dependencies

    private let httpClient: any HTTPClientContract
    private let memoryDataSource = CharacterMemoryDataSource()

    // MARK: - Init

    /// Creates a new CharacterContainer with the given HTTP client.
    /// - Parameter httpClient: The HTTP client used for network requests.
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

    func makeCharacterListViewModel(navigator: any NavigatorContract) -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: repository),
            searchCharactersUseCase: SearchCharactersUseCase(repository: repository),
            navigator: CharacterListNavigator(navigator: navigator)
        )
    }

    func makeCharacterDetailViewModel(
        identifier: Int,
        navigator: any NavigatorContract
    ) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: GetCharacterUseCase(repository: repository),
            navigator: CharacterDetailNavigator(navigator: navigator)
        )
    }
}

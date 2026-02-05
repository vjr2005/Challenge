import ChallengeCore
import ChallengeNetworking

/// Dependency container for the Character feature.
public final class CharacterContainer: Sendable {
    // MARK: - Dependencies

    private let httpClient: any HTTPClientContract
    private let tracker: any TrackerContract
    private let memoryDataSource = CharacterMemoryDataSource()
    private let recentSearchesDataSource = RecentSearchesLocalDataSource()

    // MARK: - Init

    /// Creates a new CharacterContainer with the given dependencies.
    /// - Parameters:
    ///   - httpClient: The HTTP client used for network requests.
    ///   - tracker: The tracker used to register analytics events.
    public init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
        self.httpClient = httpClient
        self.tracker = tracker
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
            refreshCharactersUseCase: RefreshCharactersUseCase(repository: repository),
            searchCharactersUseCase: SearchCharactersUseCase(repository: repository),
            getRecentSearchesUseCase: GetRecentSearchesUseCase(dataSource: recentSearchesDataSource),
            saveRecentSearchUseCase: SaveRecentSearchUseCase(dataSource: recentSearchesDataSource),
            deleteRecentSearchUseCase: DeleteRecentSearchUseCase(dataSource: recentSearchesDataSource),
            navigator: CharacterListNavigator(navigator: navigator),
            tracker: CharacterListTracker(tracker: tracker)
        )
    }

    func makeCharacterDetailViewModel(
        identifier: Int,
        navigator: any NavigatorContract
    ) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            identifier: identifier,
            getCharacterDetailUseCase: GetCharacterDetailUseCase(repository: repository),
            refreshCharacterDetailUseCase: RefreshCharacterDetailUseCase(repository: repository),
            navigator: CharacterDetailNavigator(navigator: navigator),
            tracker: CharacterDetailTracker(tracker: tracker)
        )
    }
}

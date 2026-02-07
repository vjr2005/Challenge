import ChallengeCore
import ChallengeNetworking

/// Dependency container for the Character feature.
public final class CharacterContainer: Sendable {
    // MARK: - Dependencies

    private let httpClient: any HTTPClientContract
    private let tracker: any TrackerContract
    private let memoryDataSource = CharacterMemoryDataSource()
    private let recentSearchesDataSource = RecentSearchesLocalDataSource()
    private let filterState = CharacterFilterState()

    // MARK: - Init

    /// Creates a new CharacterContainer with the given dependencies.
    /// - Parameters:
    ///   - httpClient: The HTTP client used for network requests.
    ///   - tracker: The tracker used to register analytics events.
    public init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
        self.httpClient = httpClient
        self.tracker = tracker
    }

    // MARK: - Repositories

    private var characterRepository: any CharacterRepositoryContract {
        CharacterRepository(
            remoteDataSource: CharacterRemoteDataSource(httpClient: httpClient),
            memoryDataSource: memoryDataSource
        )
    }

    private var charactersPageRepository: any CharactersPageRepositoryContract {
        CharactersPageRepository(
            remoteDataSource: CharacterRemoteDataSource(httpClient: httpClient),
            memoryDataSource: memoryDataSource
        )
    }

    // MARK: - Factories

    func makeCharacterListViewModel(navigator: any NavigatorContract) -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: charactersPageRepository),
            refreshCharactersUseCase: RefreshCharactersUseCase(repository: charactersPageRepository),
            searchCharactersUseCase: SearchCharactersUseCase(repository: charactersPageRepository),
            getRecentSearchesUseCase: GetRecentSearchesUseCase(dataSource: recentSearchesDataSource),
            saveRecentSearchUseCase: SaveRecentSearchUseCase(dataSource: recentSearchesDataSource),
            deleteRecentSearchUseCase: DeleteRecentSearchUseCase(dataSource: recentSearchesDataSource),
            navigator: CharacterListNavigator(navigator: navigator),
            tracker: CharacterListTracker(tracker: tracker),
            filterState: filterState
        )
    }

    func makeCharacterDetailViewModel(
        identifier: Int,
        navigator: any NavigatorContract
    ) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            identifier: identifier,
            getCharacterDetailUseCase: GetCharacterDetailUseCase(repository: characterRepository),
            refreshCharacterDetailUseCase: RefreshCharacterDetailUseCase(repository: characterRepository),
            navigator: CharacterDetailNavigator(navigator: navigator),
            tracker: CharacterDetailTracker(tracker: tracker)
        )
    }

    func makeAdvancedSearchViewModel(navigator: any NavigatorContract) -> AdvancedSearchViewModel {
        AdvancedSearchViewModel(
            filterState: filterState,
            navigator: AdvancedSearchNavigator(navigator: navigator),
            tracker: AdvancedSearchTracker(tracker: tracker)
        )
    }
}

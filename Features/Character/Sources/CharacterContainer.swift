import ChallengeCore
import ChallengeNetworking

/// Dependency container for the Character feature.
public final class CharacterContainer {
    // MARK: - Dependencies

    private let tracker: any TrackerContract

    // MARK: - Repositories

    private let characterRepository: any CharacterRepositoryContract
    private let recentSearchesRepository: any RecentSearchesRepositoryContract
    private let charactersPageRepository: any CharactersPageRepositoryContract

    // MARK: - Init

    /// Creates a new CharacterContainer with the given dependencies.
    /// - Parameters:
    ///   - httpClient: The HTTP client used for network requests.
    ///   - tracker: The tracker used to register analytics events.
    public init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
        self.tracker = tracker
        let remoteDataSource = CharacterRESTDataSource(httpClient: httpClient)
        let memoryDataSource = CharacterMemoryDataSource()
        let recentSearchesDataSource = RecentSearchesLocalDataSource()
        self.characterRepository = CharacterRepository(
            remoteDataSource: remoteDataSource,
            memoryDataSource: memoryDataSource
        )
        self.recentSearchesRepository = RecentSearchesRepository(
            localDataSource: recentSearchesDataSource
        )
        self.charactersPageRepository = CharactersPageRepository(
            remoteDataSource: remoteDataSource,
            memoryDataSource: memoryDataSource
        )
    }

    // MARK: - Factories

    func makeCharacterListViewModel(navigator: any NavigatorContract) -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersPageUseCase: GetCharactersPageUseCase(repository: charactersPageRepository),
            refreshCharactersPageUseCase: RefreshCharactersPageUseCase(repository: charactersPageRepository),
            searchCharactersPageUseCase: SearchCharactersPageUseCase(repository: charactersPageRepository),
            getRecentSearchesUseCase: GetRecentSearchesUseCase(repository: recentSearchesRepository),
            saveRecentSearchUseCase: SaveRecentSearchUseCase(repository: recentSearchesRepository),
            deleteRecentSearchUseCase: DeleteRecentSearchUseCase(repository: recentSearchesRepository),
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
            getCharacterUseCase: GetCharacterUseCase(repository: characterRepository),
            refreshCharacterUseCase: RefreshCharacterUseCase(repository: characterRepository),
            navigator: CharacterDetailNavigator(navigator: navigator),
            tracker: CharacterDetailTracker(tracker: tracker)
        )
    }

    func makeCharacterFilterViewModel(
        delegate: any CharacterFilterDelegate,
        navigator: any NavigatorContract
    ) -> CharacterFilterViewModel {
        CharacterFilterViewModel(
            delegate: delegate,
            navigator: CharacterFilterNavigator(navigator: navigator),
            tracker: CharacterFilterTracker(tracker: tracker)
        )
    }
}

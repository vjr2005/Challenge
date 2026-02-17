import ChallengeCore
import ChallengeNetworking

/// Dependency container for the Character feature.
public final class CharacterContainer {
    // MARK: - Dependencies

    private let tracker: any TrackerContract
    private let imageLoader: any ImageLoaderContract

    // MARK: - Repositories

    private let characterRepository: any CharacterRepositoryContract
    private let recentSearchesRepository: any RecentSearchesRepositoryContract
    private let charactersPageRepository: any CharactersPageRepositoryContract

    // MARK: - Init

    /// Creates a new CharacterContainer with the given dependencies.
    /// - Parameters:
    ///   - httpClient: The HTTP client used for network requests.
    ///   - tracker: The tracker used to register analytics events.
    ///   - imageLoader: The image loader used to manage cached images.
    public init(httpClient: any HTTPClientContract, tracker: any TrackerContract, imageLoader: any ImageLoaderContract) {
        self.tracker = tracker
        self.imageLoader = imageLoader
        let remoteDataSource = CharacterRESTDataSource(httpClient: httpClient)
        let volatileContainer = CharacterModelContainer.create(inMemoryOnly: true)
        let persistenceContainer = CharacterModelContainer.create()
        let volatileDataSource = CharacterEntityDataSource(modelContainer: volatileContainer)
        let persistenceDataSource = CharacterEntityDataSource(modelContainer: persistenceContainer)
        let recentSearchesDataSource = RecentSearchesUserDefaultsDataSource()
        self.characterRepository = CharacterRepository(
            remoteDataSource: remoteDataSource,
            volatile: volatileDataSource,
            persistence: persistenceDataSource
        )
        self.recentSearchesRepository = RecentSearchesRepository(
            localDataSource: recentSearchesDataSource
        )
        self.charactersPageRepository = CharactersPageRepository(
            remoteDataSource: remoteDataSource,
            volatile: volatileDataSource,
            persistence: persistenceDataSource
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
            imageLoader: imageLoader,
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

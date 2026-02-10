import ChallengeCore
import ChallengeNetworking

public final class EpisodeContainer {
    // MARK: - Dependencies

    private let tracker: any TrackerContract

    // MARK: - Repositories

    private let episodeRepository: EpisodeRepositoryContract

    // MARK: - Init

    public init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
        self.tracker = tracker
        let graphQLClient = GraphQLClient(httpClient: httpClient)
        let remoteDataSource = EpisodeGraphQLDataSource(graphQLClient: graphQLClient)
        let memoryDataSource = EpisodeMemoryDataSource()
        self.episodeRepository = EpisodeRepository(
            remoteDataSource: remoteDataSource,
            memoryDataSource: memoryDataSource
        )
    }

    // MARK: - Factories

    func makeEpisodeListViewModel(navigator: any NavigatorContract) -> EpisodeListViewModel {
        EpisodeListViewModel(
            navigator: EpisodeListNavigator(navigator: navigator),
            tracker: EpisodeListTracker(tracker: tracker)
        )
    }
}

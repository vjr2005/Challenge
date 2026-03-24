import ChallengeCore
import ChallengeNetworking
import SwiftUI

struct EpisodeContainer {
	// MARK: - Dependencies

	private let tracker: any TrackerContract

	// MARK: - Repositories

	private let episodeRepository: any EpisodeRepositoryContract

	// MARK: - Init

	init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
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

	func makeCharacterEpisodesView(
		characterIdentifier: Int,
		navigator: any NavigatorContract
	) -> some View {
		CharacterEpisodesView(
			viewModel: CharacterEpisodesViewModel(
				characterIdentifier: characterIdentifier,
				getCharacterEpisodesUseCase: GetCharacterEpisodesUseCase(repository: episodeRepository),
				refreshCharacterEpisodesUseCase: RefreshCharacterEpisodesUseCase(repository: episodeRepository),
				navigator: CharacterEpisodesNavigator(navigator: navigator),
				tracker: CharacterEpisodesTracker(tracker: tracker)
			)
		)
	}
}

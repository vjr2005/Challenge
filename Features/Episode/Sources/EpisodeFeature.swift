import ChallengeCore
import ChallengeNetworking
import SwiftUI

public struct EpisodeFeature: FeatureContract {
	// MARK: - Dependencies

	private let container: EpisodeContainer

	// MARK: - Init

	public init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
		self.container = EpisodeContainer(httpClient: httpClient, tracker: tracker)
	}

	// MARK: - FeatureContract

	public var deepLinkHandler: (any DeepLinkHandlerContract)? {
		EpisodeDeepLinkHandler()
	}

	public func makeMainView(navigator: any NavigatorContract) -> AnyView {
		AnyView(
			CharacterEpisodesView(
				viewModel: container.makeCharacterEpisodesViewModel(characterIdentifier: 1, navigator: navigator)
			)
		)
	}

	public func resolve(
		_ navigation: any NavigationContract,
		navigator: any NavigatorContract
	) -> AnyView? {
		guard let navigation = navigation as? EpisodeIncomingNavigation else {
			return nil
		}
		switch navigation {
		case .characterEpisodes(let characterIdentifier):
			return AnyView(
				CharacterEpisodesView(
					viewModel: container.makeCharacterEpisodesViewModel(
						characterIdentifier: characterIdentifier,
						navigator: navigator
					)
				)
			)
		}
	}
}

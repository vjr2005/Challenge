import ChallengeCore
import SwiftUI

public struct EpisodeFeature: FeatureContract {
    // MARK: - Dependencies

    private let container: EpisodeContainer

    // MARK: - Init

    public init(tracker: any TrackerContract) {
        self.container = EpisodeContainer(tracker: tracker)
    }

    // MARK: - FeatureContract

    public var deepLinkHandler: (any DeepLinkHandlerContract)? {
        EpisodeDeepLinkHandler()
    }

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView(EpisodeListView(viewModel: container.makeEpisodeListViewModel(navigator: navigator)))
    }

    public func resolve(
        _ navigation: any NavigationContract,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let navigation = navigation as? EpisodeIncomingNavigation else {
            return nil
        }
        switch navigation {
        case .main:
            return makeMainView(navigator: navigator)
        }
    }
}

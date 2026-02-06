import ChallengeCore
import SwiftUI

/// Feature entry point for the Home module.
public struct HomeFeature: FeatureContract {
    // MARK: - Dependencies

    private let container: HomeContainer

    // MARK: - Init

    /// Creates the home feature.
    /// - Parameter tracker: The tracker used to register analytics events.
    public init(tracker: any TrackerContract) {
        self.container = HomeContainer(tracker: tracker)
    }

    // MARK: - Feature Protocol

    public var deepLinkHandler: (any DeepLinkHandlerContract)? {
        HomeDeepLinkHandler()
    }

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView(HomeView(viewModel: container.makeHomeViewModel(navigator: navigator)))
    }

    public func resolve(
        _ navigation: any NavigationContract,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let navigation = navigation as? HomeIncomingNavigation else {
            return nil
        }
        switch navigation {
        case .main:
            return makeMainView(navigator: navigator)
        case .about:
            return AnyView(AboutView(
                viewModel: container.makeAboutViewModel(navigator: navigator)
            ))
        }
    }
}

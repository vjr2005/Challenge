import ChallengeCore
import SwiftUI

/// Feature entry point for the Home module.
public struct HomeFeature: Feature {
    // MARK: - Dependencies

    private let container: HomeContainer

    // MARK: - Init

    /// Creates the home feature.
    public init() {
        self.container = HomeContainer()
    }

    // MARK: - Feature Protocol

    public var deepLinkHandler: (any DeepLinkHandler)? {
        HomeDeepLinkHandler()
    }

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView(HomeView(viewModel: container.makeHomeViewModel(navigator: navigator)))
    }

    public func resolve(
        _ navigation: any Navigation,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let navigation = navigation as? HomeIncomingNavigation else {
            return nil
        }
        switch navigation {
        case .main:
            return makeMainView(navigator: navigator)
        }
    }
}

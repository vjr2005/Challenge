import ChallengeCore
import SwiftUI

/// Feature entry point for the Home module.
public struct HomeFeature: Feature {
    // MARK: - Types

    public typealias NavigationType = HomeIncomingNavigation

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

    public func resolve(
        _ navigation: HomeIncomingNavigation,
        navigator: any NavigatorContract
    ) -> AnyView {
        switch navigation {
        case .main:
            AnyView(HomeView(viewModel: container.makeHomeViewModel(navigator: navigator)))
        }
    }

    // MARK: - Factory

    /// Creates the root Home view with the given navigator.
    public func makeHomeView(navigator: any NavigatorContract) -> some View {
        HomeView(viewModel: container.makeHomeViewModel(navigator: navigator))
    }
}

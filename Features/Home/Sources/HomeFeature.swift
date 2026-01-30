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

    /// Applies navigation destinations for Home screens to the given view.
    public func applyNavigationDestination<V: View>(to view: V, navigator: any NavigatorContract) -> AnyView {
        AnyView(
            view.navigationDestination(for: HomeIncomingNavigation.self) { navigation in
                self.view(for: navigation, navigator: navigator)
            }
        )
    }

    // MARK: - Factory

    /// Creates the root Home view with the given navigator.
    public func makeHomeView(navigator: any NavigatorContract) -> some View {
        HomeView(viewModel: container.makeHomeViewModel(navigator: navigator))
    }
}

// MARK: - Internal

extension HomeFeature {
    @ViewBuilder
    func view(for navigation: HomeIncomingNavigation, navigator: any NavigatorContract) -> some View {
        switch navigation {
        case .main:
            HomeView(viewModel: container.makeHomeViewModel(navigator: navigator))
        }
    }
}

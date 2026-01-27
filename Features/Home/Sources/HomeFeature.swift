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

    /// Registers deep link handlers for the Home feature.
    public func registerDeepLinks() {
        HomeDeepLinkHandler.register()
    }

    /// Applies navigation destinations for Home screens to the given view.
    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(
            view.navigationDestination(for: HomeNavigation.self) { navigation in
                self.view(for: navigation, router: router)
            }
        )
    }

    // MARK: - Factory

    /// Creates the root Home view with the given router.
    public func makeHomeView(router: any RouterContract) -> some View {
        HomeView(viewModel: container.makeHomeViewModel(router: router))
    }
}

// MARK: - Internal

extension HomeFeature {
    @ViewBuilder
    func view(for navigation: HomeNavigation, router: any RouterContract) -> some View {
        switch navigation {
        case .main:
            HomeView(viewModel: container.makeHomeViewModel(router: router))
        }
    }
}

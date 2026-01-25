import ChallengeCore
import SwiftUI

public struct HomeFeature: Feature {
    // MARK: - Dependencies

    private let container: HomeContainer

    // MARK: - Init

    public init() {
        self.container = HomeContainer()
    }

    // MARK: - Feature Protocol

    public func registerDeepLinks() {
        HomeDeepLinkHandler.register()
    }

    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(
            view.navigationDestination(for: HomeNavigation.self) { navigation in
                self.view(for: navigation, router: router)
            }
        )
    }

    // MARK: - Factory

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

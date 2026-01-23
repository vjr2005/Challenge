import ChallengeCore
import SwiftUI

public struct HomeFeature: Feature {
    public init() {}

    // MARK: - Feature Protocol

    @MainActor
    public func registerDeepLinks() {
        // Home has no deep links
    }

    @MainActor
    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(view)
    }

    // MARK: - Factory

    @MainActor
    public func makeHomeView(router: any RouterContract) -> some View {
        HomeView(viewModel: HomeViewModel(navigator: HomeNavigator(router: router)))
    }
}

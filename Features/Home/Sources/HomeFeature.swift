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
        // Home has no deep links
    }

    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(view)
    }

    // MARK: - Factory

    public func makeHomeView(router: any RouterContract) -> some View {
        HomeView(viewModel: container.makeHomeViewModel(router: router))
    }
}

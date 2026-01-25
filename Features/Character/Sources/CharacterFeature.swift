import ChallengeCore
import ChallengeNetworking
import SwiftUI

public struct CharacterFeature: Feature {
    // MARK: - Dependencies

    private let container: CharacterContainer

    // MARK: - Init

    public init(httpClient: any HTTPClientContract) {
        self.container = CharacterContainer(httpClient: httpClient)
    }

    // MARK: - Feature Protocol

    public func registerDeepLinks() {
        CharacterDeepLinkHandler.register()
    }

    public func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView {
        AnyView(
            view.navigationDestination(for: CharacterNavigation.self) { navigation in
                self.view(for: navigation, router: router)
            }
        )
    }
}

// MARK: - Internal

extension CharacterFeature {
    @ViewBuilder
    func view(for navigation: CharacterNavigation, router: any RouterContract) -> some View {
        switch navigation {
        case .list:
            CharacterListView(viewModel: container.makeCharacterListViewModel(router: router))
        case .detail(let identifier):
            CharacterDetailView(
                viewModel: container.makeCharacterDetailViewModel(
                    identifier: identifier,
                    router: router
                )
            )
        }
    }
}

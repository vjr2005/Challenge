import ChallengeCore
import ChallengeNetworking
import SwiftUI

/// Feature entry point for the Character module.
public struct CharacterFeature: Feature {
    // MARK: - Dependencies

    private let container: CharacterContainer

    // MARK: - Init

    /// Creates the character feature with the given HTTP client.
    public init(httpClient: any HTTPClientContract) {
        self.container = CharacterContainer(httpClient: httpClient)
    }

    // MARK: - Feature Protocol

    /// Registers deep link handlers for the Character feature.
    public func registerDeepLinks() {
        CharacterDeepLinkHandler.register()
    }

    /// Applies navigation destinations for Character screens to the given view.
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

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

    public var deepLinkHandler: any DeepLinkHandler {
        CharacterDeepLinkHandler()
    }

    /// Applies navigation destinations for Character screens to the given view.
    public func applyNavigationDestination<V: View>(to view: V, navigator: any NavigatorContract) -> AnyView {
        AnyView(
            view.navigationDestination(for: CharacterIncomingNavigation.self) { navigation in
                self.view(for: navigation, navigator: navigator)
            }
        )
    }
}

// MARK: - Internal

extension CharacterFeature {
    @ViewBuilder
    func view(for navigation: CharacterIncomingNavigation, navigator: any NavigatorContract) -> some View {
        switch navigation {
        case .list:
            CharacterListView(viewModel: container.makeCharacterListViewModel(navigator: navigator))
        case .detail(let identifier):
            CharacterDetailView(
                viewModel: container.makeCharacterDetailViewModel(
                    identifier: identifier,
                    navigator: navigator
                )
            )
        }
    }
}

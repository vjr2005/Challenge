import ChallengeCore
import ChallengeNetworking
import SwiftUI

/// Feature entry point for the Character module.
public struct CharacterFeature: FeatureContract {
    // MARK: - Dependencies

    private let container: CharacterContainer

    // MARK: - Init

    /// Creates the character feature with the given HTTP client.
    public init(httpClient: any HTTPClientContract) {
        self.container = CharacterContainer(httpClient: httpClient)
    }

    // MARK: - Feature Protocol

    public var deepLinkHandler: (any DeepLinkHandlerContract)? {
        CharacterDeepLinkHandler()
    }

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView(CharacterListView(
            viewModel: container.makeCharacterListViewModel(navigator: navigator)
        ))
    }

    public func resolve(
        _ navigation: any NavigationContract,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let navigation = navigation as? CharacterIncomingNavigation else {
            return nil
        }
        switch navigation {
        case .list:
            return makeMainView(navigator: navigator)
        case .detail(let identifier):
            return AnyView(CharacterDetailView(
                viewModel: container.makeCharacterDetailViewModel(
                    identifier: identifier,
                    navigator: navigator
                )
            ))
        }
    }
}

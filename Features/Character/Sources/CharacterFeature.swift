import ChallengeCore
import ChallengeNetworking
import SwiftUI

/// Feature entry point for the Character module.
public struct CharacterFeature: Feature {
    // MARK: - Types

    public typealias NavigationType = CharacterIncomingNavigation

    // MARK: - Dependencies

    private let container: CharacterContainer

    // MARK: - Init

    /// Creates the character feature with the given HTTP client.
    public init(httpClient: any HTTPClientContract) {
        self.container = CharacterContainer(httpClient: httpClient)
    }

    // MARK: - Feature Protocol

    public var deepLinkHandler: (any DeepLinkHandler)? {
        CharacterDeepLinkHandler()
    }

    public func resolve(
        _ navigation: CharacterIncomingNavigation,
        navigator: any NavigatorContract
    ) -> AnyView {
        switch navigation {
        case .list:
            AnyView(CharacterListView(
                viewModel: container.makeCharacterListViewModel(navigator: navigator)
            ))
        case .detail(let identifier):
            AnyView(CharacterDetailView(
                viewModel: container.makeCharacterDetailViewModel(
                    identifier: identifier,
                    navigator: navigator
                )
            ))
        }
    }
}

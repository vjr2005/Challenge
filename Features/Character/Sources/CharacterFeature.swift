import ChallengeCore
import ChallengeNetworking
import SwiftUI

/// Feature entry point for the Character module.
public struct CharacterFeature: FeatureContract {
    // MARK: - Dependencies

    private let container: CharacterContainer

    // MARK: - Init

    /// Creates the character feature with the given dependencies.
    /// - Parameters:
    ///   - httpClient: The HTTP client used for network requests.
    ///   - tracker: The tracker used to register analytics events.
    public init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
        self.container = CharacterContainer(httpClient: httpClient, tracker: tracker)
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
        case .characterFilter(let delegate):
            return AnyView(CharacterFilterView(
                viewModel: container.makeCharacterFilterViewModel(
                    delegate: delegate,
                    navigator: navigator
                )
            ))
        }
    }
}

import ChallengeCore
import SwiftUI

public enum CharacterFeature {
    private static let container = CharacterContainer()

    // MARK: - Deep Links

    /// Registers deep link handlers for this feature.
    /// Call from `App.init()` to enable deep link navigation.
    @MainActor
    public static func registerDeepLinks() {
        CharacterDeepLinkHandler.register()
    }

    // MARK: - Views

    /// Builds the view for a navigation destination.
    /// Only used by App layer for `navigationDestination(for:)` registration.
    @ViewBuilder
    public static func view(for navigation: CharacterNavigation, router: RouterContract) -> some View {
        switch navigation {
        case .list:
            CharacterListView(viewModel: container.makeCharacterListViewModel(router: router))
        case .detail(let identifier):
            CharacterDetailView(viewModel: container.makeCharacterDetailViewModel(identifier: identifier, router: router))
        }
    }
}

import ChallengeCore
import SwiftUI

public enum CharacterFeature {
    private static let container = CharacterContainer()

    /// Builds the view for a navigation destination.
    /// Only used by App layer for `navigationDestination(for:)` registration.
    @ViewBuilder
    public static func view(for navigation: CharacterNavigation, router: RouterContract) -> some View {
        switch navigation {
        case .detail(let identifier):
            CharacterView(viewModel: container.makeCharacterViewModel(identifier: identifier, router: router))
        }
    }
}

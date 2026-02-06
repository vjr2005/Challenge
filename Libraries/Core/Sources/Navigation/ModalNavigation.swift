import SwiftUI

/// Wraps a navigation destination with its modal presentation style.
/// Used as the item for `.sheet(item:)` and `.fullScreenCover(item:)` modifiers.
public struct ModalNavigation: Identifiable {
    public let id = UUID()
    public let navigation: AnyNavigation
    public let style: ModalPresentationStyle

    /// Creates a new modal navigation.
    /// - Parameters:
    ///   - navigation: The navigation destination to present modally.
    ///   - style: The presentation style (sheet or fullScreenCover).
    public init(navigation: any NavigationContract, style: ModalPresentationStyle) {
        self.navigation = AnyNavigation(navigation)
        self.style = style
    }

    /// The detents for sheet presentation. Empty set for fullScreenCover.
    public var detents: Set<PresentationDetent> {
        if case .sheet(let detents) = style {
            return detents
        }
        return []
    }
}

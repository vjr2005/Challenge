import SwiftUI

/// Protocol that defines a feature module's navigation resolution capabilities.
public protocol FeatureContract {
    /// The deep link handler for this feature (optional).
    var deepLinkHandler: (any DeepLinkHandlerContract)? { get }

    /// Creates the main view for this feature.
    /// This is the default entry point view.
    /// - Parameter navigator: The navigator for the view to use.
    /// - Returns: The main view for this feature.
    func makeMainView(navigator: any NavigatorContract) -> AnyView

    /// Resolves a navigation destination to a view.
    /// Returns nil if this feature doesn't handle the given navigation.
    /// - Parameters:
    ///   - navigation: The navigation destination to resolve.
    ///   - navigator: The navigator for the resolved view to use.
    /// - Returns: The view for the given navigation, or nil if not handled.
    func resolve(_ navigation: any NavigationContract, navigator: any NavigatorContract) -> AnyView?
}

// MARK: - Default Implementations

public extension FeatureContract {
    var deepLinkHandler: (any DeepLinkHandlerContract)? { nil }
}

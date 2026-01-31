import SwiftUI

/// Protocol that defines a feature module's navigation resolution capabilities.
public protocol Feature {
    /// The navigation type this feature handles.
    associatedtype NavigationType: IncomingNavigation

    /// The deep link handler for this feature (optional).
    var deepLinkHandler: (any DeepLinkHandler)? { get }

    /// Resolves a navigation destination to a view.
    /// This method is type-safe and always returns a view.
    /// - Parameters:
    ///   - navigation: The navigation destination to resolve.
    ///   - navigator: The navigator for the resolved view to use.
    /// - Returns: The view for the given navigation.
    func resolve(_ navigation: NavigationType, navigator: any NavigatorContract) -> AnyView
}

// MARK: - Default Implementations

public extension Feature {
    var deepLinkHandler: (any DeepLinkHandler)? { nil }

    /// Attempts to resolve any navigation destination.
    /// Returns nil if the navigation type doesn't match this feature's NavigationType.
    /// This is auto-generated from the type-safe resolve method.
    /// - Parameters:
    ///   - navigation: The navigation destination to resolve.
    ///   - navigator: The navigator for the resolved view to use.
    /// - Returns: The view if this feature handles the navigation, nil otherwise.
    func tryResolve(
        _ navigation: any IncomingNavigation,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let typed = navigation as? NavigationType else {
            return nil
        }
        return resolve(typed, navigator: navigator)
    }
}

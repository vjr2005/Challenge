import Foundation

/// Protocol for redirecting navigation between features.
/// Implemented in App layer to connect outgoing to incoming navigation.
public protocol NavigationRedirectContract: Sendable {
    /// Redirects the navigation if applicable.
    /// - Parameter navigation: The original navigation.
    /// - Returns: The redirected navigation, or nil if no redirect applies.
    func redirect(_ navigation: any Navigation) -> (any Navigation)?
}

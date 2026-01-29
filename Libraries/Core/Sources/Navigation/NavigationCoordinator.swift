import Foundation
import SwiftUI

/// Coordinates navigation by managing the navigation path and applying redirects.
/// This is the single source of truth for navigation state.
@Observable
public final class NavigationCoordinator: NavigatorContract {
    /// The current navigation path.
    public var path = NavigationPath()

    private let redirector: (any NavigationRedirectContract)?

    /// Creates a new navigation coordinator.
    /// - Parameter redirector: Optional redirector for cross-feature navigation.
    public init(redirector: (any NavigationRedirectContract)? = nil) {
        self.redirector = redirector
    }

    /// Navigates to the given destination, applying redirect if configured.
    public func navigate(to destination: any Navigation) {
        let resolved = redirector?.redirect(destination) ?? destination
        path.append(resolved)
    }

    /// Navigates back to the previous screen.
    public func goBack() {
        guard !path.isEmpty else {
            return
        }
        path.removeLast()
    }
}

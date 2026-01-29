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
    ///
    /// - For `OutgoingNavigation`: Requires a redirect; falls back to `UnknownNavigation` if none.
    /// - For other `Navigation`: Appends directly to the path.
    public func navigate(to destination: any Navigation) {
        guard destination is any OutgoingNavigation else {
            path.append(destination)
            return
        }

        if let redirected = redirector?.redirect(destination) {
            path.append(redirected)
        } else {
            path.append(UnknownNavigation.notFound)
        }
    }

    /// Navigates back to the previous screen.
    public func goBack() {
        guard !path.isEmpty else {
            return
        }
        path.removeLast()
    }
}

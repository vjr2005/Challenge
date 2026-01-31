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
        let resolved: any IncomingNavigation

        if let incoming = destination as? any IncomingNavigation {
            resolved = incoming
        } else if destination is any OutgoingNavigation {
            if let redirected = redirector?.redirect(destination) as? any IncomingNavigation {
                resolved = redirected
            } else {
                resolved = UnknownNavigation.notFound
            }
        } else {
            resolved = UnknownNavigation.notFound
        }

        path.append(AnyIncomingNavigation(resolved))
    }

    /// Navigates back to the previous screen.
    public func goBack() {
        guard !path.isEmpty else {
            return
        }
        path.removeLast()
    }
}

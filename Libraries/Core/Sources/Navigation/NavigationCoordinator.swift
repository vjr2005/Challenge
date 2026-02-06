import Foundation
import SwiftUI

/// Coordinates navigation by managing the navigation path, modals, and applying redirects.
/// This is the single source of truth for navigation state.
@Observable
public final class NavigationCoordinator: NavigatorContract {
    /// The current navigation path.
    public var path = NavigationPath()

    /// The currently presented sheet modal, if any.
    public var sheetNavigation: ModalNavigation?

    /// The currently presented full-screen cover modal, if any.
    public var fullScreenCoverNavigation: ModalNavigation?

    private let redirector: (any NavigationRedirectContract)?
    private let onDismiss: (() -> Void)?

    /// Creates a new navigation coordinator.
    /// - Parameters:
    ///   - redirector: Optional redirector for cross-feature navigation.
    ///   - onDismiss: Optional closure invoked when dismiss is called with no modals presented.
    public init(
        redirector: (any NavigationRedirectContract)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.redirector = redirector
        self.onDismiss = onDismiss
    }

    /// Navigates to the given destination, applying redirect if configured.
    ///
    /// - For `OutgoingNavigationContract`: Requires a redirect; falls back to `UnknownNavigation` if none.
    /// - For other `NavigationContract`: Appends directly to the path.
    public func navigate(to destination: any NavigationContract) {
        let resolved = resolveRedirect(destination)
        path.append(AnyNavigation(resolved))
    }

    /// Presents a destination modally with the given style, applying redirect if configured.
    public func present(_ destination: any NavigationContract, style: ModalPresentationStyle) {
        let resolved = resolveRedirect(destination)
        let modal = ModalNavigation(navigation: resolved, style: style)
        switch style {
        case .sheet:
            sheetNavigation = modal
        case .fullScreenCover:
            fullScreenCoverNavigation = modal
        }
    }

    /// Dismisses the topmost modal. Priority: fullScreenCover > sheet > parent onDismiss.
    public func dismiss() {
        if fullScreenCoverNavigation != nil {
            fullScreenCoverNavigation = nil
        } else if sheetNavigation != nil {
            sheetNavigation = nil
        } else {
            onDismiss?()
        }
    }

    /// Navigates back to the previous screen.
    public func goBack() {
        guard !path.isEmpty else {
            return
        }
        path.removeLast()
    }

    // MARK: - Private

    private func resolveRedirect(_ destination: any NavigationContract) -> any NavigationContract {
        if destination is any OutgoingNavigationContract {
            if let redirected = redirector?.redirect(destination) {
                return redirected
            }
            return UnknownNavigation.notFound
        }
        return destination
    }
}

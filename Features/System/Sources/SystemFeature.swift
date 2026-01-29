import ChallengeCore
import SwiftUI

/// Feature entry point for the System module.
/// Handles system-level navigation like unknown routes.
public struct SystemFeature: Feature {
    // MARK: - Dependencies

    private let container: SystemContainer

    // MARK: - Init

    public init() {
        self.container = SystemContainer()
    }

    // MARK: - Feature Protocol

    public var deepLinkHandler: any DeepLinkHandler {
        SystemDeepLinkHandler()
    }

    /// Applies navigation destinations for System screens to the given view.
    public func applyNavigationDestination<V: View>(to view: V, navigator: any NavigatorContract) -> AnyView {
        AnyView(
            view.navigationDestination(for: UnknownNavigation.self) { _ in
                NotFoundView(viewModel: container.makeNotFoundViewModel(navigator: navigator))
            }
        )
    }
}

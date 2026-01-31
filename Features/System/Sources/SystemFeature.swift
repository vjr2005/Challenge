import ChallengeCore
import SwiftUI

/// Feature entry point for the System module.
/// Handles system-level navigation like unknown routes.
public struct SystemFeature: Feature {
    // MARK: - Types

    public typealias NavigationType = UnknownNavigation

    // MARK: - Dependencies

    private let container: SystemContainer

    // MARK: - Init

    public init() {
        self.container = SystemContainer()
    }

    // MARK: - Feature Protocol

    public func resolve(
        _ navigation: UnknownNavigation,
        navigator: any NavigatorContract
    ) -> AnyView {
        switch navigation {
        case .notFound:
            AnyView(NotFoundView(viewModel: container.makeNotFoundViewModel(navigator: navigator)))
        }
    }
}

import ChallengeCore
import SwiftUI

/// Feature entry point for the System module.
/// Handles system-level navigation like unknown routes.
public struct SystemFeature: FeatureContract {
    // MARK: - Dependencies

    private let container: SystemContainer

    // MARK: - Init

    /// Creates the system feature.
    /// - Parameter tracker: The tracker used to register analytics events.
    public init(tracker: any TrackerContract) {
        self.container = SystemContainer(tracker: tracker)
    }

    // MARK: - Feature Protocol

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView(NotFoundView(viewModel: container.makeNotFoundViewModel(navigator: navigator)))
    }

    public func resolve(
        _ navigation: any NavigationContract,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let navigation = navigation as? UnknownNavigation else {
            return nil
        }
        switch navigation {
        case .notFound:
            return makeMainView(navigator: navigator)
        }
    }
}

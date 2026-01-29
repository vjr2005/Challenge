import SwiftUI

/// Protocol that defines a feature module's capabilities.
public protocol Feature {
    /// The deep link handler for this feature.
    var deepLinkHandler: any DeepLinkHandler { get }

    /// Applies navigation destinations for this feature to a view.
    func applyNavigationDestination<V: View>(to view: V, navigator: any NavigatorContract) -> AnyView
}

public extension View {
    /// Applies navigation destinations from all features.
    func withNavigationDestinations(features: [any Feature], navigator: any NavigatorContract) -> some View {
        features.reduce(AnyView(self)) { view, feature in
            feature.applyNavigationDestination(to: view, navigator: navigator)
        }
    }
}

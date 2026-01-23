import SwiftUI

/// Protocol that defines a feature module's capabilities.
public protocol Feature {
    /// Registers deep link handlers for this feature.
    func registerDeepLinks()

    /// Applies navigation destinations for this feature to a view.
    func applyNavigationDestination<V: View>(to view: V, router: any RouterContract) -> AnyView
}

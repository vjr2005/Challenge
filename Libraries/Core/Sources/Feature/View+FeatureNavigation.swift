import SwiftUI

public extension View {
    /// Applies all navigation destinations from the provided features.
    func withNavigationDestinations(features: [any Feature], router: any RouterContract) -> some View {
        features.reduce(AnyView(self)) { view, feature in
            feature.applyNavigationDestination(to: view, router: router)
        }
    }
}

import Foundation
import SwiftUI

/// Default router implementation using NavigationPath.
/// Uses DeepLinkRegistry.shared for URL resolution.
@Observable
public final class Router: RouterContract {
    /// The current navigation path.
    public var path = NavigationPath()

    /// Creates a new router.
    public init() {}

    /// Navigates to the given destination by appending it to the path.
    public func navigate(to destination: any Navigation) {
        path.append(destination)
    }

    /// Resolves the URL via the deep link registry and navigates to the result.
    public func navigate(to url: URL?) {
        guard let url,
              let destination = DeepLinkRegistry.shared.resolve(url) else {
            return
        }
        path.append(destination)
    }

    /// Removes the last destination from the navigation path.
    public func goBack() {
        guard !path.isEmpty else {
            return
        }
        path.removeLast()
    }
}

import Foundation
import SwiftUI

/// Default router implementation using NavigationPath.
/// Uses DeepLinkRegistry.shared for URL resolution.
@Observable
public final class Router: RouterContract {
    public var path = NavigationPath()

    public init() {}

    public func navigate(to destination: any Navigation) {
        path.append(destination)
    }

    public func navigate(to url: URL?) {
        guard let url,
              let destination = DeepLinkRegistry.shared.resolve(url) else {
            return
        }
        path.append(destination)
    }

    public func goBack() {
        guard !path.isEmpty else {
            return
        }
        path.removeLast()
    }
}

import SwiftUI

/// Default router implementation using NavigationPath.
@Observable
public final class Router: RouterContract {
    public var path = NavigationPath()

    public init() {}

    public func navigate(to destination: any Navigation) {
        path.append(destination)
    }

    public func goBack() {
        guard !path.isEmpty else {
            return
        }
        path.removeLast()
    }
}

import SwiftUI

/// Default router implementation using NavigationPath.
public final class Router: RouterContract {
    private let path: Binding<NavigationPath>

    public init(path: Binding<NavigationPath>) {
        self.path = path
    }

    public func navigate(to destination: any Navigation) {
        path.wrappedValue.append(destination)
    }

    public func goBack() {
        guard !path.wrappedValue.isEmpty else {
            return
        }
        path.wrappedValue.removeLast()
    }
}

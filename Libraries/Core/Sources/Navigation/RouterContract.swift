/// Protocol for navigation routing.
/// Implementations manage `NavigationPath` and provide navigation methods.
public protocol RouterContract {
    /// Navigates to a destination.
    /// - Parameter destination: The navigation destination conforming to `Navigation`.
    func navigate(to destination: any Navigation)

    /// Navigates back to the previous screen.
    func goBack()
}

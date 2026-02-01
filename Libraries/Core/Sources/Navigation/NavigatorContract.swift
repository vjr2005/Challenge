import Foundation

/// Protocol that features use for navigation.
/// This abstraction hides implementation details like redirects from the features.
public protocol NavigatorContract {
    /// Navigates to the specified destination.
    func navigate(to destination: any NavigationContract)

    /// Navigates back to the previous screen.
    func goBack()
}

import Foundation

/// Protocol that features use for navigation.
/// This abstraction hides implementation details like redirects from the features.
public protocol NavigatorContract {
    /// Navigates to the specified destination via push.
    func navigate(to destination: any NavigationContract)

    /// Presents a destination modally with the given style.
    func present(_ destination: any NavigationContract, style: ModalPresentationStyle)

    /// Dismisses the current modal. If no modal is presented, invokes the parent's dismiss.
    func dismiss()

    /// Navigates back to the previous screen.
    func goBack()
}

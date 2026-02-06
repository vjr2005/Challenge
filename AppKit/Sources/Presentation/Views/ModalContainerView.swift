import ChallengeCore
import SwiftUI

/// Recursive container view that provides its own `NavigationCoordinator` for each modal presentation.
/// Enables push navigation within modals and nested modal presentations.
struct ModalContainerView: View {
	let modal: ModalNavigation
	let appContainer: AppContainer
	let onDismiss: () -> Void

	@State private var navigationCoordinator: NavigationCoordinator

	init(modal: ModalNavigation, appContainer: AppContainer, onDismiss: @escaping () -> Void) {
		self.modal = modal
		self.appContainer = appContainer
		self.onDismiss = onDismiss
		_navigationCoordinator = State(initialValue: NavigationCoordinator(
			redirector: AppNavigationRedirect(),
			onDismiss: onDismiss
		))
	}

	var body: some View {
		NavigationContainerView(navigationCoordinator: navigationCoordinator, appContainer: appContainer) {
			appContainer.resolve(modal.navigation.wrapped, navigator: navigationCoordinator)
		}
	}
}

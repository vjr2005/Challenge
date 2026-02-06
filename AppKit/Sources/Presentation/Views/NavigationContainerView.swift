import ChallengeCore
import SwiftUI

/// Reusable container that provides a `NavigationStack` with push and modal navigation support.
/// Used by both `RootContainerView` (root level) and `ModalContainerView` (inside modals).
struct NavigationContainerView<Content: View>: View {
	@Bindable var navigationCoordinator: NavigationCoordinator
	let appContainer: AppContainer
	@ViewBuilder let content: Content

	var body: some View {
		NavigationStack(path: $navigationCoordinator.path) {
			content
				.navigationDestination(for: AnyNavigation.self) { navigation in
					appContainer.resolve(navigation.wrapped, navigator: navigationCoordinator)
				}
		}
		.sheet(item: $navigationCoordinator.sheetNavigation) { modal in
			ModalContainerView(modal: modal, appContainer: appContainer) {
				navigationCoordinator.sheetNavigation = nil
			}
			.presentationDetents(modal.detents)
		}
		.fullScreenCover(item: $navigationCoordinator.fullScreenCoverNavigation) { modal in
			ModalContainerView(modal: modal, appContainer: appContainer) {
				navigationCoordinator.fullScreenCoverNavigation = nil
			}
		}
	}
}

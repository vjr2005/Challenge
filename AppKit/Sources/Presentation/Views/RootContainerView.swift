import ChallengeCore
import SwiftUI

public struct RootContainerView: View {
	public let appContainer: AppContainer

	@State private var navigationCoordinator = NavigationCoordinator(redirector: AppNavigationRedirect())

	public init(appContainer: AppContainer) {
		self.appContainer = appContainer
	}

	public var body: some View {
		NavigationContainerView(navigationCoordinator: navigationCoordinator, appContainer: appContainer) {
			appContainer.makeRootView(navigator: navigationCoordinator)
		}
		.onOpenURL { url in
			appContainer.handle(url: url, navigator: navigationCoordinator)
		}
	}
}

/*
// MARK: - Previews

#Preview {
	RootContainerView(appContainer: AppContainer())
}
*/

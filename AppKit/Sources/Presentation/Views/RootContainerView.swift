import ChallengeCore
import SwiftUI

public struct RootContainerView: View {
	public let appContainer: AppContainer

	@State private var navigationCoordinator = NavigationCoordinator(redirector: AppNavigationRedirect())

	public init(appContainer: AppContainer) {
		self.appContainer = appContainer
	}

	public var body: some View {
		NavigationStack(path: $navigationCoordinator.path) {
			appContainer.makeRootView(navigator: navigationCoordinator)
				.navigationDestination(for: AnyNavigation.self) { navigation in
					appContainer.resolve(navigation.wrapped, navigator: navigationCoordinator)
				}
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

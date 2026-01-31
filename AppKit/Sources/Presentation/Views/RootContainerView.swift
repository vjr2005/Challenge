import ChallengeCore
import SwiftUI

public struct RootContainerView: View {
	public let appContainer: AppContainer

	@State private var navigationCoordinator: NavigationCoordinator

	public init(appContainer: AppContainer) {
		self.appContainer = appContainer
		_navigationCoordinator = State(initialValue: NavigationCoordinator(redirector: AppNavigationRedirect()))
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

#Preview {
	RootContainerView(appContainer: AppContainer())
}

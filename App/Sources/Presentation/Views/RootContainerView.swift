import ChallengeCore
import SwiftUI

struct RootContainerView: View {
    let appContainer: AppContainer
    @State private var navigationCoordinator = NavigationCoordinator(redirector: AppNavigationRedirect())

    var body: some View {
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

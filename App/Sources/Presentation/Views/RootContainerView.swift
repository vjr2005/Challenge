import ChallengeCore
import ChallengeHome
import SwiftUI

struct RootContainerView: View {
    let appContainer: AppContainer
    @State private var coordinator = NavigationCoordinator(redirector: AppNavigationRedirect())

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            appContainer.makeRootView(navigator: coordinator)
                .withNavigationDestinations(features: appContainer.features, navigator: coordinator)
        }
        .onOpenURL { url in
            appContainer.handle(url: url, navigator: coordinator)
        }
    }
}

#Preview {
    RootContainerView(appContainer: AppContainer())
}

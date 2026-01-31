import ChallengeCore
import SwiftUI

struct RootContainerView: View {
    let appContainer: AppContainer
    @State private var navigatorCoordinator = NavigationCoordinator(redirector: AppNavigationRedirect())

    var body: some View {
        NavigationStack(path: $navigatorCoordinator.path) {
            appContainer.makeRootView(navigator: navigatorCoordinator)
                .withNavigationDestinations(features: appContainer.features, navigator: navigatorCoordinator)
        }
        .onOpenURL { url in
            appContainer.handle(url: url, navigator: navigatorCoordinator)
        }
    }
}

#Preview {
    RootContainerView(appContainer: AppContainer())
}

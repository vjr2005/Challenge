import ChallengeCore
import Foundation

/// Navigator for Home screen.
/// Uses hardcoded URLs for external navigation (deep links).
struct HomeNavigator: HomeNavigatorContract {
    private let router: RouterContract

    init(router: RouterContract) {
        self.router = router
    }

    func navigateToCharacters() {
        // EXTERNAL navigation: URL hardcoded (optional, no force unwrap needed)
        router.navigate(to: URL(string: "challenge://character/list"))
    }
}

import ChallengeCore
import Foundation

struct HomeNavigator: HomeNavigatorContract {
    private let router: RouterContract

    init(router: RouterContract) {
        self.router = router
    }

    func navigateToCharacters() {
        router.navigate(to: URL(string: "challenge://character/list"))
    }
}

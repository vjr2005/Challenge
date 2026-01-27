import ChallengeCore

struct CharacterListNavigator: CharacterListNavigatorContract {
    private let router: RouterContract

    init(router: RouterContract) {
        self.router = router
    }

    func navigateToDetail(id: Int) {
        router.navigate(to: CharacterNavigation.detail(identifier: id))
    }
}

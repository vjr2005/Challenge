import ChallengeCore

struct CharacterDetailNavigator: CharacterDetailNavigatorContract {
    private let router: RouterContract

    init(router: RouterContract) {
        self.router = router
    }

    func goBack() {
        router.goBack()
    }
}

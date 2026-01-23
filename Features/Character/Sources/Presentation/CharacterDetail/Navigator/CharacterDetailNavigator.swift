import ChallengeCore

/// Navigator for Character Detail screen.
struct CharacterDetailNavigator: CharacterDetailNavigatorContract {
    private let router: RouterContract

    init(router: RouterContract) {
        self.router = router
    }

    func goBack() {
        router.goBack()
    }
}

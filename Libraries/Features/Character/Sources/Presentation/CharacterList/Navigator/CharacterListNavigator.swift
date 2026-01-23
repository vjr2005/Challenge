import ChallengeCore

/// Navigator for Character List screen.
/// Uses Navigation directly for internal navigation.
struct CharacterListNavigator: CharacterListNavigatorContract {
    private let router: RouterContract

    init(router: RouterContract) {
        self.router = router
    }

    func navigateToDetail(id: Int) {
        // INTERNAL navigation: uses Navigation directly
        router.navigate(to: CharacterNavigation.detail(identifier: id))
    }
}

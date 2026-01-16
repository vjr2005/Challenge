import ChallengeCore

final class HomeContainer {
    func makeHomeViewModel(router: RouterContract) -> HomeViewModel {
        HomeViewModel(router: router)
    }
}

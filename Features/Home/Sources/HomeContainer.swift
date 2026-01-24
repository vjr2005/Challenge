import ChallengeCore

public final class HomeContainer: Sendable {
    // MARK: - Init

    public init() {}

    // MARK: - Factories

    func makeHomeViewModel(router: any RouterContract) -> HomeViewModel {
        HomeViewModel(navigator: HomeNavigator(router: router))
    }
}

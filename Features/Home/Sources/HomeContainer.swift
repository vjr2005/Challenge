import ChallengeCore

/// Dependency container for the Home feature.
public final class HomeContainer: Sendable {
    // MARK: - Init

    /// Creates a new home container.
    public init() {}

    // MARK: - Factories

    func makeHomeViewModel(navigator: any NavigatorContract) -> HomeViewModel {
        HomeViewModel(navigator: HomeNavigator(navigator: navigator))
    }
}

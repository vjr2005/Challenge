import ChallengeCore

/// Dependency container for the Home feature.
public final class HomeContainer: Sendable {
    // MARK: - Init

    /// Creates a new home container.
    public init() {}

    // MARK: - Factories

    func makeHomeViewModel(router: any RouterContract) -> HomeViewModel {
        HomeViewModel(navigator: HomeNavigator(router: router))
    }
}

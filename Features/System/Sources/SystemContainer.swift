import ChallengeCore

/// Dependency container for the System feature.
public final class SystemContainer: Sendable {
    // MARK: - Init

    public init() {}

    // MARK: - Factories

    func makeNotFoundViewModel(navigator: any NavigatorContract) -> NotFoundViewModel {
        NotFoundViewModel(navigator: NotFoundNavigator(navigator: navigator))
    }
}

import ChallengeCore
import SwiftUI

/// Dependency container for the Home feature.
struct HomeContainer {
    // MARK: - Dependencies

    private let tracker: any TrackerContract

    // MARK: - Init

    /// Creates a new home container.
    /// - Parameter tracker: The tracker used to register analytics events.
    init(tracker: any TrackerContract) {
        self.tracker = tracker
    }

    // MARK: - Factories

    func makeHomeView(navigator: any NavigatorContract) -> some View {
        HomeView(
            viewModel: HomeViewModel(
                navigator: HomeNavigator(navigator: navigator),
                tracker: HomeTracker(tracker: tracker)
            )
        )
    }

    func makeAboutView(navigator: any NavigatorContract) -> some View {
        AboutView(
            viewModel: AboutViewModel(
                getAboutInfoUseCase: GetAboutInfoUseCase(),
                navigator: AboutNavigator(navigator: navigator),
                tracker: AboutTracker(tracker: tracker)
            )
        )
    }
}

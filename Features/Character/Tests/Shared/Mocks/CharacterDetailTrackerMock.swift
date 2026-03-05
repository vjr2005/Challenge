@testable import ChallengeCharacter

final class CharacterDetailTrackerMock: CharacterDetailTrackerContract {
    private(set) var screenViewedIdentifiers: [Int] = []
    private(set) var retryButtonTappedCallCount = 0
    private(set) var pullToRefreshTriggeredCallCount = 0
    private(set) var episodesButtonTappedIdentifiers: [Int] = []
    private(set) var loadErrorDescriptions: [String] = []
    private(set) var refreshErrorDescriptions: [String] = []

    func trackScreenViewed(identifier: Int) {
        screenViewedIdentifiers.append(identifier)
    }

    func trackRetryButtonTapped() {
        retryButtonTappedCallCount += 1
    }

    func trackPullToRefreshTriggered() {
        pullToRefreshTriggeredCallCount += 1
    }

    func trackEpisodesButtonTapped(identifier: Int) {
        episodesButtonTappedIdentifiers.append(identifier)
    }

    func trackLoadError(description: String) {
        loadErrorDescriptions.append(description)
    }

    func trackRefreshError(description: String) {
        refreshErrorDescriptions.append(description)
    }

    // MARK: - Reset

    func reset() {
        screenViewedIdentifiers = []
        retryButtonTappedCallCount = 0
        pullToRefreshTriggeredCallCount = 0
        episodesButtonTappedIdentifiers = []
        loadErrorDescriptions = []
        refreshErrorDescriptions = []
    }
}

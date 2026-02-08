@testable import ChallengeCharacter

final class CharacterDetailTrackerMock: CharacterDetailTrackerContract {
    private(set) var screenViewedIdentifiers: [Int] = []
    private(set) var retryButtonTappedCallCount = 0
    private(set) var pullToRefreshTriggeredCallCount = 0
    private(set) var backButtonTappedCallCount = 0
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

    func trackBackButtonTapped() {
        backButtonTappedCallCount += 1
    }

    func trackLoadError(description: String) {
        loadErrorDescriptions.append(description)
    }

    func trackRefreshError(description: String) {
        refreshErrorDescriptions.append(description)
    }
}

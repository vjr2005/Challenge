@testable import ChallengeCharacter

final class CharacterListTrackerMock: CharacterListTrackerContract {
    private(set) var screenViewedCallCount = 0
    private(set) var selectedIdentifiers: [Int] = []
    private(set) var searchedQueries: [String] = []
    private(set) var retryButtonTappedCallCount = 0
    private(set) var pullToRefreshTriggeredCallCount = 0
    private(set) var loadMoreButtonTappedCallCount = 0
    private(set) var advancedSearchButtonTappedCallCount = 0

    func trackScreenViewed() {
        screenViewedCallCount += 1
    }

    func trackCharacterSelected(identifier: Int) {
        selectedIdentifiers.append(identifier)
    }

    func trackSearchPerformed(query: String) {
        searchedQueries.append(query)
    }

    func trackRetryButtonTapped() {
        retryButtonTappedCallCount += 1
    }

    func trackPullToRefreshTriggered() {
        pullToRefreshTriggeredCallCount += 1
    }

    func trackLoadMoreButtonTapped() {
        loadMoreButtonTappedCallCount += 1
    }

    func trackAdvancedSearchButtonTapped() {
        advancedSearchButtonTappedCallCount += 1
    }
}

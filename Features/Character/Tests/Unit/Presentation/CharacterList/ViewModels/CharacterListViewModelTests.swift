import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterListViewModelTests {
    // MARK: - Properties

    private let getCharactersPageUseCaseMock = GetCharactersPageUseCaseMock()
    private let refreshCharactersPageUseCaseMock = RefreshCharactersPageUseCaseMock()
    private let searchCharactersPageUseCaseMock = SearchCharactersPageUseCaseMock()
    private let getRecentSearchesUseCaseMock = GetRecentSearchesUseCaseMock()
    private let saveRecentSearchUseCaseMock = SaveRecentSearchUseCaseMock()
    private let deleteRecentSearchUseCaseMock = DeleteRecentSearchUseCaseMock()
    private let navigatorMock = CharacterListNavigatorMock()
    private let trackerMock = CharacterListTrackerMock()
    private let sut: CharacterListViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterListViewModel(
            getCharactersPageUseCase: getCharactersPageUseCaseMock,
            refreshCharactersPageUseCase: refreshCharactersPageUseCaseMock,
            searchCharactersPageUseCase: searchCharactersPageUseCaseMock,
            getRecentSearchesUseCase: getRecentSearchesUseCaseMock,
            saveRecentSearchUseCase: saveRecentSearchUseCaseMock,
            deleteRecentSearchUseCase: deleteRecentSearchUseCaseMock,
            navigator: navigatorMock,
            tracker: trackerMock,
            debounceInterval: .zero
        )
    }

    // MARK: - Initial State

    @Test("Initial state is idle before loading")
    func initialStateIsIdle() {
        // Then
        #expect(sut.state == .idle)
    }

    // MARK: - didAppear

    @Test("didAppear produces expected outcome per scenario", arguments: DidAppearScenario.all)
    func didAppear(scenario: DidAppearScenario) async {
        // Given
        getCharactersPageUseCaseMock.result = scenario.given.charactersPageResult
        searchCharactersPageUseCaseMock.result = scenario.given.charactersPageResult
        getRecentSearchesUseCaseMock.searches = scenario.given.recentSearches
        if !scenario.given.searchQuery.isEmpty {
            await givenActiveSearchQuery(scenario.given.searchQuery)
        }

        // When
        await sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
        #expect(getCharactersPageUseCaseMock.executeCallCount == scenario.expected.getCharactersPageExecuteCallCount)
        #expect(getCharactersPageUseCaseMock.lastRequestedPage == scenario.expected.lastRequestedPage)
        #expect(searchCharactersPageUseCaseMock.executeCallCount == scenario.expected.searchCharactersPageExecuteCallCount)
        #expect(searchCharactersPageUseCaseMock.lastRequestedFilter?.name == scenario.expected.searchFilterName)
        #expect(sut.state == scenario.expected.state)
        #expect(trackerMock.fetchErrorDescriptions == scenario.expected.fetchErrorDescriptions)
        #expect(sut.recentSearches == scenario.expected.recentSearches)
    }

    // MARK: - didTapOnRetryButton

    @Test("didTapOnRetryButton produces expected outcome per scenario", arguments: DidTapOnRetryButtonScenario.all)
    func didTapOnRetryButton(scenario: DidTapOnRetryButtonScenario) async {
        // Given
        await givenErrorState()
        getCharactersPageUseCaseMock.result = scenario.given.charactersPageResult

        // When
        await sut.didTapOnRetryButton()

        // Then
        #expect(getCharactersPageUseCaseMock.executeCallCount == 1)
        #expect(getCharactersPageUseCaseMock.lastRequestedPage == 1)
        #expect(trackerMock.retryButtonTappedCallCount == 1)
        #expect(sut.state == scenario.expected.state)
        #expect(trackerMock.fetchErrorDescriptions == scenario.expected.fetchErrorDescriptions)
    }

    // MARK: - didTapOnLoadMoreButton

    @Test("didTapOnLoadMoreButton produces expected outcome per scenario", arguments: DidTapOnLoadMoreButtonScenario.all)
    func didTapOnLoadMoreButton(scenario: DidTapOnLoadMoreButtonScenario) async {
        // Given
        await givenLoadedStateWithNextPage()
        getCharactersPageUseCaseMock.result = scenario.given.charactersPageResult

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(trackerMock.loadMoreButtonTappedCallCount == 1)
        #expect(getCharactersPageUseCaseMock.executeCallCount == 1)
        #expect(getCharactersPageUseCaseMock.lastRequestedPage == 2)
        #expect(searchCharactersPageUseCaseMock.executeCallCount == 0)
        #expect(sut.state == scenario.expected.state)
        #expect(trackerMock.loadMoreErrorDescriptions == scenario.expected.loadMoreErrorDescriptions)
    }

    @Test("didTapOnLoadMoreButton with search query produces expected outcome per scenario", arguments: DidTapOnLoadMoreButtonWithSearchQueryScenario.all)
    func didTapOnLoadMoreButtonWithSearchQuery(scenario: DidTapOnLoadMoreButtonWithSearchQueryScenario) async {
        // Given
        await givenLoadedStateWithNextPageAndSearchQuery(scenario.given.searchQuery)
        searchCharactersPageUseCaseMock.result = scenario.given.charactersPageResult

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(trackerMock.loadMoreButtonTappedCallCount == 1)
        #expect(searchCharactersPageUseCaseMock.executeCallCount == 1)
        #expect(searchCharactersPageUseCaseMock.lastRequestedPage == 2)
        #expect(searchCharactersPageUseCaseMock.lastRequestedFilter?.name == scenario.given.searchQuery)
        #expect(getCharactersPageUseCaseMock.executeCallCount == 0)
        #expect(sut.state == scenario.expected.state)
        #expect(trackerMock.loadMoreErrorDescriptions == scenario.expected.loadMoreErrorDescriptions)
    }

    @Test("didTapOnLoadMoreButton with character filter produces expected outcome per scenario", arguments: DidTapOnLoadMoreButtonWithCharacterFilterScenario.all)
    func didTapOnLoadMoreButtonWithCharacterFilter(scenario: DidTapOnLoadMoreButtonWithCharacterFilterScenario) async {
        // Given
        await givenLoadedStateWithNextPageAndCharacterFilter(scenario.given.characterFilter)
        searchCharactersPageUseCaseMock.result = scenario.given.charactersPageResult

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(trackerMock.loadMoreButtonTappedCallCount == 1)
        #expect(searchCharactersPageUseCaseMock.executeCallCount == 1)
        #expect(searchCharactersPageUseCaseMock.lastRequestedPage == 2)
        #expect(searchCharactersPageUseCaseMock.lastRequestedFilter?.status == scenario.given.characterFilter.status)
        #expect(getCharactersPageUseCaseMock.executeCallCount == 0)
        #expect(sut.state == scenario.expected.state)
        #expect(trackerMock.loadMoreErrorDescriptions == scenario.expected.loadMoreErrorDescriptions)
    }

    @Test("didTapOnLoadMoreButton does nothing when no next page available")
    func didTapOnLoadMoreButtonDoesNothingWhenNoNextPage() async {
        // Given
        await givenLoadedStateWithoutNextPage()

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(getCharactersPageUseCaseMock.executeCallCount == 0)
        #expect(trackerMock.loadMoreButtonTappedCallCount == 0)
    }

    @Test("didTapOnLoadMoreButton reverts page number on error for retry")
    func didTapOnLoadMoreButtonRevertsPageOnError() async {
        // Given
        await givenLoadedStateWithNextPage()
        getCharactersPageUseCaseMock.result = .failure(.loadFailed())
        await sut.didTapOnLoadMoreButton()

        // When - retry after error
        getCharactersPageUseCaseMock.result = .success(CharactersPage.stub(currentPage: 2))
        await sut.didTapOnLoadMoreButton()

        // Then - should request page 2 again, not page 3
        #expect(getCharactersPageUseCaseMock.lastRequestedPage == 2)
    }

    // MARK: - Navigation

    @Test("Selecting character navigates to detail and tracks selection")
    func didSelectNavigatesToCharacterDetailAndTracksSelection() {
        // Given
        let character = Character.stub(id: 42)

        // When
        sut.didSelect(character)

        // Then
        #expect(navigatorMock.navigateToDetailIdentifiers == [42])
        #expect(trackerMock.selectedIdentifiers == [42])
    }

    // MARK: - Search

    @Test("Search query change triggers search use case after debounce delay")
    func searchQueryChangeTriggersSearchAfterDebounce() async {
        // Given
        searchCharactersPageUseCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // Then
        #expect(searchCharactersPageUseCaseMock.lastRequestedFilter?.name == "Rick")
    }

    @Test("Rapid search query changes only trigger one load")
    func rapidSearchQueryChangesOnlyTriggersOneLoad() async {
        // Given
        searchCharactersPageUseCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "R"
        sut.searchQuery = "Ri"
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // Then
        #expect(searchCharactersPageUseCaseMock.executeCallCount == 1)
        #expect(searchCharactersPageUseCaseMock.lastRequestedFilter?.name == "Rick")
    }

    @Test("Whitespace-only search query uses get characters use case")
    func whitespaceOnlySearchQueryUsesGetCharactersPageUseCase() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "   "
        await sut.searchTask?.value

        // Then
        #expect(getCharactersPageUseCaseMock.executeCallCount == 1)
        #expect(searchCharactersPageUseCaseMock.executeCallCount == 0)
    }

    @Test("Search query change resets to page one")
    func searchQueryChangeResetsToPageOne() async {
        // Given
        await givenLoadedStateOnPage2()

        // When
        searchCharactersPageUseCaseMock.result = .success(.stub())
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // Then
        #expect(searchCharactersPageUseCaseMock.lastRequestedPage == 1)
    }

    @Test("Search with no results sets emptySearch state")
    func searchWithNoResultsSetsEmptySearchState() async {
        // Given
        let emptyPage = CharactersPage.stub(characters: [])
        searchCharactersPageUseCaseMock.result = .success(emptyPage)

        // When
        sut.searchQuery = "NonExistent"
        await sut.searchTask?.value

        // Then
        #expect(sut.state == .emptySearch)
    }

    @Test("Clearing search query before debounce only triggers one load")
    func clearingSearchQueryBeforeDebounceOnlyTriggersOneLoad() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "Rick"
        sut.searchQuery = ""
        await sut.searchTask?.value

        // Then
        #expect(getCharactersPageUseCaseMock.executeCallCount == 1)
        #expect(searchCharactersPageUseCaseMock.executeCallCount == 0)
    }

    // MARK: - didPullToRefresh

    @Test("didPullToRefresh produces expected outcome per scenario", arguments: DidPullToRefreshScenario.all)
    func didPullToRefresh(scenario: DidPullToRefreshScenario) async {
        // Given
        if scenario.given.loadMoreBeforeRefresh {
            await givenLoadedStateOnPage2()
        } else {
            await givenLoadedState()
        }
        refreshCharactersPageUseCaseMock.result = scenario.given.charactersPageResult

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(refreshCharactersPageUseCaseMock.executeCallCount == 1)
        #expect(refreshCharactersPageUseCaseMock.lastRequestedPage == 1)
        #expect(trackerMock.pullToRefreshTriggeredCallCount == 1)
        #expect(sut.state == scenario.expected.state)
        #expect(trackerMock.refreshErrorDescriptions == scenario.expected.refreshErrorDescriptions)
    }

    @Test("didPullToRefresh keeps loaded state visible during network request")
    func didPullToRefreshKeepsLoadedStateDuringRequest() async {
        // Given
        await givenLoadedState()
        refreshCharactersPageUseCaseMock.result = .success(.stub())

        var statesDuringRefresh: [CharacterListViewState] = []
        refreshCharactersPageUseCaseMock.onExecute = { [weak sut] in
            guard let sut else { return }
            statesDuringRefresh.append(sut.state)
        }

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(statesDuringRefresh.count == 1)
        #expect(statesDuringRefresh.first == .loaded(.stub()))
    }

    @Test("didPullToRefresh followed by load more fetches next page from use case")
    func didPullToRefreshFollowedByLoadMoreFetchesNextPage() async {
        // Given
        await givenLoadedStateWithNextPage()
        getCharactersPageUseCaseMock.result = .success(CharactersPage.stub(
            characters: [Character.stub(id: 2)],
            currentPage: 2,
            hasNextPage: true
        ))
        await sut.didTapOnLoadMoreButton()

        // When - pull to refresh resets to page 1
        let refreshedPage = CharactersPage.stub(
            characters: [Character.stub(id: 10)],
            currentPage: 1,
            hasNextPage: true
        )
        refreshCharactersPageUseCaseMock.result = .success(refreshedPage)
        await sut.didPullToRefresh()

        // Then - load more should fetch page 2 via getCharactersPageUseCase
        let thirdPage = CharactersPage.stub(
            characters: [Character.stub(id: 11)],
            currentPage: 2,
            hasNextPage: false
        )
        getCharactersPageUseCaseMock.result = .success(thirdPage)
        let callCountBefore = getCharactersPageUseCaseMock.executeCallCount
        await sut.didTapOnLoadMoreButton()

        #expect(getCharactersPageUseCaseMock.executeCallCount == callCountBefore + 1)
        #expect(getCharactersPageUseCaseMock.lastRequestedPage == 2)
    }

    // MARK: - Tracking

    @Test("Search query change tracks search performed after debounce")
    func searchQueryChangeTracksSearchPerformed() async {
        // Given
        searchCharactersPageUseCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // Then
        #expect(trackerMock.searchedQueries == ["Rick"])
    }

    @Test("Empty search query does not track search performed")
    func emptySearchQueryDoesNotTrackSearchPerformed() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "Rick"
        sut.searchQuery = ""
        await sut.searchTask?.value

        // Then
        #expect(trackerMock.searchedQueries.isEmpty)
    }

    // MARK: - Recent Searches

    @Test("Search saves to recent searches after debounce")
    func searchSavesToRecentSearchesAfterDebounce() async {
        // Given
        searchCharactersPageUseCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // Then
        #expect(saveRecentSearchUseCaseMock.savedQueries == ["Rick"])
    }

    @Test("Empty search query does not save to recent searches")
    func emptySearchQueryDoesNotSave() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = ""
        await sut.searchTask?.value

        // Then
        #expect(saveRecentSearchUseCaseMock.executeCallCount == 0)
    }

    @Test("Whitespace-only search query does not save to recent searches")
    func whitespaceOnlySearchQueryDoesNotSave() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "   "
        await sut.searchTask?.value

        // Then
        #expect(saveRecentSearchUseCaseMock.executeCallCount == 0)
    }

    @Test("Recent searches refreshed after save")
    func recentSearchesRefreshedAfterSave() async {
        // Given
        searchCharactersPageUseCaseMock.result = .success(.stub())
        getRecentSearchesUseCaseMock.searches = ["Rick"]

        // When
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // Then
        #expect(sut.recentSearches == ["Rick"])
        #expect(getRecentSearchesUseCaseMock.executeCallCount >= 1)
    }

    @Test("didSelectRecentSearch sets query, searches, saves, and tracks")
    func didSelectRecentSearch() async {
        // Given
        searchCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didSelectRecentSearch("Rick")

        // Then
        #expect(sut.searchQuery == "Rick")
        #expect(searchCharactersPageUseCaseMock.executeCallCount == 1)
        #expect(searchCharactersPageUseCaseMock.lastRequestedFilter?.name == "Rick")
        #expect(saveRecentSearchUseCaseMock.savedQueries == ["Rick"])
        #expect(trackerMock.searchedQueries == ["Rick"])
    }

    @Test("didDeleteRecentSearch deletes query and refreshes list")
    func didDeleteRecentSearch() async {
        // Given
        getRecentSearchesUseCaseMock.searches = ["Morty"]

        // When
        await sut.didDeleteRecentSearch("Rick")

        // Then
        #expect(deleteRecentSearchUseCaseMock.deletedQueries == ["Rick"])
        #expect(sut.recentSearches == ["Morty"])
        #expect(getRecentSearchesUseCaseMock.executeCallCount >= 1)
    }

    // MARK: - Character Filter

    @Test("didTapCharacterFilterButton navigates to filter and tracks event")
    func didTapCharacterFilterButton() {
        // When
        sut.didTapCharacterFilterButton()

        // Then
        #expect(navigatorMock.presentCharacterFilterCallCount == 1)
        #expect(navigatorMock.lastPresentCharacterFilterDelegate === sut)
        #expect(trackerMock.characterFilterButtonTappedCallCount == 1)
    }

    @Test("applyCharacterFilters triggers fetch characters")
    func applyCharacterFiltersTriggersFetchCharacters() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())
        let filter = CharacterFilter.empty

        // When
        await sut.applyCharacterFilters(filter)

        // Then
        #expect(getCharactersPageUseCaseMock.executeCallCount == 1)
    }

    @Test("applyCharacterFilters uses search use case when filter has active filters")
    func applyCharacterFiltersUsesSearchUseCaseWhenFilterHasActiveFilters() async {
        // Given
        searchCharactersPageUseCaseMock.result = .success(.stub())
        let filter = CharacterFilter(status: .alive)

        // When
        await sut.applyCharacterFilters(filter)

        // Then
        #expect(searchCharactersPageUseCaseMock.executeCallCount == 1)
        #expect(searchCharactersPageUseCaseMock.lastRequestedFilter?.status == .alive)
        #expect(getCharactersPageUseCaseMock.executeCallCount == 0)
    }

    @Test("applyCharacterFilters updates activeFilterCount")
    func applyCharacterFiltersUpdatesActiveFilterCount() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())
        let filter = CharacterFilter(status: .alive, gender: .male)

        // When
        await sut.applyCharacterFilters(filter)

        // Then
        #expect(sut.activeFilterCount == 2)
    }

    @Test("applyCharacterFilters combines name and filter state")
    func applyCharacterFiltersCombinesNameAndFilterState() async {
        // Given
        searchCharactersPageUseCaseMock.result = .success(.stub())
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // When
        let filter = CharacterFilter(status: .alive)
        await sut.applyCharacterFilters(filter)

        // Then
        let requestedFilter = searchCharactersPageUseCaseMock.lastRequestedFilter
        #expect(requestedFilter?.name == "Rick")
        #expect(requestedFilter?.status == .alive)
    }

    @Test("fetchCharacters ignores error when search task is cancelled during network request")
    func fetchCharactersIgnoresErrorDuringCancelledSearch() async {
        // Given
        await givenLoadedState()
        searchCharactersPageUseCaseMock.result = .failure(.loadFailed())

        // When
        await withCheckedContinuation { continuation in
            searchCharactersPageUseCaseMock.onExecute = {
                continuation.resume()
                try? await Task.sleep(for: .seconds(1))
            }
            sut.searchQuery = "Rick"
        }
        sut.searchTask?.cancel()
        await sut.searchTask?.value

        // Then
        #expect(sut.state == .loaded(.stub()))
    }

    @Test("currentFilter reflects applied filter")
    func currentFilterReflectsAppliedFilter() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())
        let filter = CharacterFilter(status: .alive, species: "Human")

        // When
        await sut.applyCharacterFilters(filter)

        // Then
        #expect(sut.currentFilter == filter)
    }

    // MARK: - Helpers

    private func givenLoadedState() async {
        getCharactersPageUseCaseMock.result = .success(.stub())
        await sut.didAppear()
        getCharactersPageUseCaseMock.reset()
        trackerMock.reset()
    }

    private func givenErrorState() async {
        getCharactersPageUseCaseMock.result = .failure(.loadFailed())
        await sut.didAppear()
        getCharactersPageUseCaseMock.reset()
        trackerMock.reset()
    }

    private func givenLoadedStateWithNextPage() async {
        let firstPage = CharactersPage.stub(
            characters: [Character.stub(id: 1)],
            currentPage: 1,
            hasNextPage: true
        )
        getCharactersPageUseCaseMock.result = .success(firstPage)
        await sut.didAppear()
        getCharactersPageUseCaseMock.reset()
        searchCharactersPageUseCaseMock.reset()
        trackerMock.reset()
    }

    private func givenLoadedStateWithNextPageAndSearchQuery(_ query: String) async {
        let firstPage = CharactersPage.stub(
            characters: [Character.stub(id: 1)],
            currentPage: 1,
            hasNextPage: true
        )
        searchCharactersPageUseCaseMock.result = .success(firstPage)
        sut.searchQuery = query
        await sut.searchTask?.value
        await sut.didAppear()
        searchCharactersPageUseCaseMock.reset()
        getCharactersPageUseCaseMock.reset()
        trackerMock.reset()
    }

    private func givenLoadedStateWithNextPageAndCharacterFilter(_ filter: CharacterFilter) async {
        let firstPage = CharactersPage.stub(
            characters: [Character.stub(id: 1)],
            currentPage: 1,
            hasNextPage: true
        )
        searchCharactersPageUseCaseMock.result = .success(firstPage)
        await sut.applyCharacterFilters(filter)
        searchCharactersPageUseCaseMock.reset()
        getCharactersPageUseCaseMock.reset()
        trackerMock.reset()
    }

    private func givenLoadedStateWithoutNextPage() async {
        getCharactersPageUseCaseMock.result = .success(.stub(hasNextPage: false))
        await sut.didAppear()
        getCharactersPageUseCaseMock.reset()
        trackerMock.reset()
    }

    private func givenLoadedStateOnPage2() async {
        await givenLoadedStateWithNextPage()
        getCharactersPageUseCaseMock.result = .success(CharactersPage.stub(currentPage: 2))
        await sut.didTapOnLoadMoreButton()
        getCharactersPageUseCaseMock.reset()
        trackerMock.reset()
    }

    private func givenActiveSearchQuery(_ query: String) async {
        sut.searchQuery = query
        await sut.searchTask?.value
        searchCharactersPageUseCaseMock.reset()
        trackerMock.reset()
    }

}

// MARK: - Test Helpers

extension CharacterListViewModelTests {
    nonisolated struct DidAppearScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let charactersPageResult: Result<CharactersPage, CharactersPageError>
            let recentSearches: [String]
            let searchQuery: String
        }

        struct Expected: Sendable {
            let state: CharacterListViewState
            let fetchErrorDescriptions: [String]
            let recentSearches: [String]
            let getCharactersPageExecuteCallCount: Int
            let lastRequestedPage: Int?
            let searchCharactersPageExecuteCallCount: Int
            let searchFilterName: String?
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [DidAppearScenario] = [
            DidAppearScenario(
                testDescription: "On success sets loaded state without tracking error",
                given: Given(charactersPageResult: .success(.stub()), recentSearches: [], searchQuery: ""),
                expected: Expected(
                    state: .loaded(.stub()),
                    fetchErrorDescriptions: [],
                    recentSearches: [],
                    getCharactersPageExecuteCallCount: 1,
                    lastRequestedPage: 1,
                    searchCharactersPageExecuteCallCount: 0,
                    searchFilterName: nil
                )
            ),
            DidAppearScenario(
                testDescription: "On success with empty characters sets empty state",
                given: Given(charactersPageResult: .success(.stub(characters: [])), recentSearches: [], searchQuery: ""),
                expected: Expected(
                    state: .empty,
                    fetchErrorDescriptions: [],
                    recentSearches: [],
                    getCharactersPageExecuteCallCount: 1,
                    lastRequestedPage: 1,
                    searchCharactersPageExecuteCallCount: 0,
                    searchFilterName: nil
                )
            ),
            DidAppearScenario(
                testDescription: "On failure sets error state and tracks fetch error",
                given: Given(charactersPageResult: .failure(.loadFailed()), recentSearches: [], searchQuery: ""),
                expected: Expected(
                    state: .error(.loadFailed()),
                    fetchErrorDescriptions: [CharactersPageError.loadFailed().debugDescription],
                    recentSearches: [],
                    getCharactersPageExecuteCallCount: 1,
                    lastRequestedPage: 1,
                    searchCharactersPageExecuteCallCount: 0,
                    searchFilterName: nil
                )
            ),
            DidAppearScenario(
                testDescription: "On success loads recent searches",
                given: Given(charactersPageResult: .success(.stub()), recentSearches: ["Rick", "Morty"], searchQuery: ""),
                expected: Expected(
                    state: .loaded(.stub()),
                    fetchErrorDescriptions: [],
                    recentSearches: ["Rick", "Morty"],
                    getCharactersPageExecuteCallCount: 1,
                    lastRequestedPage: 1,
                    searchCharactersPageExecuteCallCount: 0,
                    searchFilterName: nil
                )
            ),
            DidAppearScenario(
                testDescription: "With search query uses search use case instead of get characters",
                given: Given(charactersPageResult: .success(.stub()), recentSearches: [], searchQuery: "Morty"),
                expected: Expected(
                    state: .loaded(.stub()),
                    fetchErrorDescriptions: [],
                    recentSearches: [],
                    getCharactersPageExecuteCallCount: 0,
                    lastRequestedPage: nil,
                    searchCharactersPageExecuteCallCount: 1,
                    searchFilterName: "Morty"
                )
            ),
        ]
    }

    nonisolated struct DidTapOnRetryButtonScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let charactersPageResult: Result<CharactersPage, CharactersPageError>
        }

        struct Expected: Sendable {
            let state: CharacterListViewState
            let fetchErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [DidTapOnRetryButtonScenario] = [
            DidTapOnRetryButtonScenario(
                testDescription: "On success sets loaded state without tracking error",
                given: Given(charactersPageResult: .success(.stub())),
                expected: Expected(state: .loaded(.stub()), fetchErrorDescriptions: [])
            ),
            DidTapOnRetryButtonScenario(
                testDescription: "On failure sets error state and tracks fetch error",
                given: Given(charactersPageResult: .failure(.loadFailed())),
                expected: Expected(
                    state: .error(.loadFailed()),
                    fetchErrorDescriptions: [CharactersPageError.loadFailed().debugDescription]
                )
            ),
        ]
    }

    nonisolated struct DidTapOnLoadMoreButtonScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let charactersPageResult: Result<CharactersPage, CharactersPageError>
        }

        struct Expected: Sendable {
            let state: CharacterListViewState
            let loadMoreErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [DidTapOnLoadMoreButtonScenario] = [
            DidTapOnLoadMoreButtonScenario(
                testDescription: "On success appends characters and updates state",
                given: Given(
                    charactersPageResult: .success(.stub(
                        characters: [Character.stub(id: 2)],
                        currentPage: 2,
                        hasNextPage: false
                    ))
                ),
                expected: Expected(
                    state: .loaded(.stub(
                        characters: [Character.stub(id: 1), Character.stub(id: 2)],
                        currentPage: 2,
                        hasNextPage: false,
                        hasPreviousPage: false
                    )),
                    loadMoreErrorDescriptions: []
                )
            ),
            DidTapOnLoadMoreButtonScenario(
                testDescription: "On failure keeps existing data and tracks load more error",
                given: Given(
                    charactersPageResult: .failure(.loadFailed())
                ),
                expected: Expected(
                    state: .loaded(.stub(
                        characters: [Character.stub(id: 1)],
                        currentPage: 1,
                        hasNextPage: true
                    )),
                    loadMoreErrorDescriptions: [CharactersPageError.loadFailed().debugDescription]
                )
            ),
        ]
    }

    nonisolated struct DidTapOnLoadMoreButtonWithSearchQueryScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let charactersPageResult: Result<CharactersPage, CharactersPageError>
            let searchQuery: String
        }

        struct Expected: Sendable {
            let state: CharacterListViewState
            let loadMoreErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [DidTapOnLoadMoreButtonWithSearchQueryScenario] = [
            DidTapOnLoadMoreButtonWithSearchQueryScenario(
                testDescription: "On success appends characters and updates state",
                given: Given(
                    charactersPageResult: .success(.stub(
                        characters: [Character.stub(id: 2)],
                        currentPage: 2,
                        hasNextPage: false
                    )),
                    searchQuery: "Summer"
                ),
                expected: Expected(
                    state: .loaded(.stub(
                        characters: [Character.stub(id: 1), Character.stub(id: 2)],
                        currentPage: 2,
                        hasNextPage: false,
                        hasPreviousPage: false
                    )),
                    loadMoreErrorDescriptions: []
                )
            ),
            DidTapOnLoadMoreButtonWithSearchQueryScenario(
                testDescription: "On failure keeps existing data and tracks load more error",
                given: Given(
                    charactersPageResult: .failure(.loadFailed()),
                    searchQuery: "Summer"
                ),
                expected: Expected(
                    state: .loaded(.stub(
                        characters: [Character.stub(id: 1)],
                        currentPage: 1,
                        hasNextPage: true
                    )),
                    loadMoreErrorDescriptions: [CharactersPageError.loadFailed().debugDescription]
                )
            ),
        ]
    }

    nonisolated struct DidTapOnLoadMoreButtonWithCharacterFilterScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let charactersPageResult: Result<CharactersPage, CharactersPageError>
            let characterFilter: CharacterFilter
        }

        struct Expected: Sendable {
            let state: CharacterListViewState
            let loadMoreErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [DidTapOnLoadMoreButtonWithCharacterFilterScenario] = [
            DidTapOnLoadMoreButtonWithCharacterFilterScenario(
                testDescription: "On success appends characters and updates state",
                given: Given(
                    charactersPageResult: .success(.stub(
                        characters: [Character.stub(id: 2)],
                        currentPage: 2,
                        hasNextPage: false
                    )),
                    characterFilter: CharacterFilter(status: .dead)
                ),
                expected: Expected(
                    state: .loaded(.stub(
                        characters: [Character.stub(id: 1), Character.stub(id: 2)],
                        currentPage: 2,
                        hasNextPage: false,
                        hasPreviousPage: false
                    )),
                    loadMoreErrorDescriptions: []
                )
            ),
            DidTapOnLoadMoreButtonWithCharacterFilterScenario(
                testDescription: "On failure keeps existing data and tracks load more error",
                given: Given(
                    charactersPageResult: .failure(.loadFailed()),
                    characterFilter: CharacterFilter(status: .dead)
                ),
                expected: Expected(
                    state: .loaded(.stub(
                        characters: [Character.stub(id: 1)],
                        currentPage: 1,
                        hasNextPage: true
                    )),
                    loadMoreErrorDescriptions: [CharactersPageError.loadFailed().debugDescription]
                )
            ),
        ]
    }

    nonisolated struct DidPullToRefreshScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let charactersPageResult: Result<CharactersPage, CharactersPageError>
            let loadMoreBeforeRefresh: Bool
        }

        struct Expected: Sendable {
            let state: CharacterListViewState
            let refreshErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [DidPullToRefreshScenario] = [
            DidPullToRefreshScenario(
                testDescription: "On success sets loaded state without tracking error",
                given: Given(charactersPageResult: .success(.stub()), loadMoreBeforeRefresh: false),
                expected: Expected(state: .loaded(.stub()), refreshErrorDescriptions: [])
            ),
            DidPullToRefreshScenario(
                testDescription: "On success with empty characters sets empty state",
                given: Given(charactersPageResult: .success(.stub(characters: [])), loadMoreBeforeRefresh: false),
                expected: Expected(state: .empty, refreshErrorDescriptions: [])
            ),
            DidPullToRefreshScenario(
                testDescription: "On failure sets error state and tracks refresh error",
                given: Given(charactersPageResult: .failure(.loadFailed()), loadMoreBeforeRefresh: false),
                expected: Expected(
                    state: .error(.loadFailed()),
                    refreshErrorDescriptions: [CharactersPageError.loadFailed().debugDescription]
                )
            ),
            DidPullToRefreshScenario(
                testDescription: "After loading more pages resets to page one on success",
                given: Given(charactersPageResult: .success(.stub()), loadMoreBeforeRefresh: true),
                expected: Expected(state: .loaded(.stub()), refreshErrorDescriptions: [])
            ),
        ]
    }
}

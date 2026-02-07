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
    private let filterState = CharacterFilterState()
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
            filterState: filterState,
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

    @Test("didAppear sets loaded state with characters on success")
    func didAppearSetsLoadedStateOnSuccess() async {
        // Given
        let expected = CharactersPage.stub()
        getCharactersPageUseCaseMock.result = .success(expected)

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("didAppear sets empty state when no characters returned")
    func didAppearSetsEmptyStateWhenNoCharacters() async {
        // Given
        let emptyPage = CharactersPage.stub(characters: [])
        getCharactersPageUseCaseMock.result = .success(emptyPage)

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .empty)
    }

    @Test("didAppear sets error state on failure")
    func didAppearSetsErrorStateOnFailure() async {
        // Given
        getCharactersPageUseCaseMock.result = .failure(.loadFailed)

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test("didAppear calls use case requesting page one")
    func didAppearCallsUseCaseWithPageOne() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didAppear()

        // Then
        #expect(getCharactersPageUseCaseMock.executeCallCount == 1)
        #expect(getCharactersPageUseCaseMock.lastRequestedPage == 1)
    }

    // MARK: - didTapOnRetryButton

    @Test("didTapOnRetryButton retries loading when in error state")
    func didTapOnRetryButtonRetriesWhenError() async {
        // Given
        getCharactersPageUseCaseMock.result = .failure(.loadFailed)
        await sut.didAppear()

        // When
        getCharactersPageUseCaseMock.result = .success(.stub())
        await sut.didTapOnRetryButton()

        // Then
        #expect(getCharactersPageUseCaseMock.executeCallCount == 2)
    }

    @Test("didTapOnRetryButton always loads regardless of current state")
    func didTapOnRetryButtonAlwaysLoads() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())
        await sut.didAppear()
        #expect(getCharactersPageUseCaseMock.executeCallCount == 1)

        // When
        await sut.didTapOnRetryButton()

        // Then
        #expect(getCharactersPageUseCaseMock.executeCallCount == 2)
    }

    // MARK: - didTapOnLoadMoreButton

    @Test("didTapOnLoadMoreButton appends new characters to existing list")
    func didTapOnLoadMoreButtonAppendsCharactersToExistingPage() async {
        // Given
        let firstPageCharacters = [Character.stub(id: 1)]
        let secondPageCharacters = [Character.stub(id: 2)]
        let firstPage = CharactersPage.stub(characters: firstPageCharacters, currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(characters: secondPageCharacters, currentPage: 2, hasNextPage: false)
        getCharactersPageUseCaseMock.result = .success(firstPage)
        await sut.didAppear()
        getCharactersPageUseCaseMock.result = .success(secondPage)

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        let expected = CharactersPage.stub(
            characters: [Character.stub(id: 1), Character.stub(id: 2)],
            currentPage: 2,
            hasNextPage: false,
            hasPreviousPage: false
        )
        #expect(sut.state == .loaded(expected))
    }

    @Test("didTapOnLoadMoreButton increments page number")
    func didTapOnLoadMoreButtonIncrementsPage() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        getCharactersPageUseCaseMock.result = .success(firstPage)
        await sut.didAppear()

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(getCharactersPageUseCaseMock.lastRequestedPage == 2)
    }

    @Test("didTapOnLoadMoreButton does nothing when no next page available")
    func didTapOnLoadMoreButtonDoesNothingWhenNoNextPage() async {
        // Given
        let lastPage = CharactersPage.stub(hasNextPage: false)
        getCharactersPageUseCaseMock.result = .success(lastPage)
        await sut.didAppear()

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(getCharactersPageUseCaseMock.executeCallCount == 1)
    }

    @Test("didTapOnLoadMoreButton keeps existing data on error")
    func didTapOnLoadMoreButtonKeepsExistingDataOnError() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        getCharactersPageUseCaseMock.result = .success(firstPage)
        await sut.didAppear()
        getCharactersPageUseCaseMock.result = .failure(.loadFailed)

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(sut.state == .loaded(firstPage))
    }

    @Test("didTapOnLoadMoreButton reverts page number on error for retry")
    func didTapOnLoadMoreButtonRevertsPageOnError() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        getCharactersPageUseCaseMock.result = .success(firstPage)
        await sut.didAppear()
        getCharactersPageUseCaseMock.result = .failure(.loadFailed)
        await sut.didTapOnLoadMoreButton()

        // When - retry after error
        getCharactersPageUseCaseMock.result = .success(CharactersPage.stub(currentPage: 2))
        await sut.didTapOnLoadMoreButton()

        // Then - should request page 2 again, not page 3
        #expect(getCharactersPageUseCaseMock.lastRequestedPage == 2)
    }

    // MARK: - Navigation

    @Test("Selecting character navigates to detail screen")
    func didSelectNavigatesToCharacterDetail() {
        // Given
        let character = Character.stub(id: 42)

        // When
        sut.didSelect(character)

        // Then
        #expect(navigatorMock.navigateToDetailIdentifiers == [42])
    }

    // MARK: - Search

    @Test("Initial searchQuery is empty string")
    func initialSearchQueryIsEmpty() {
        // Then
        #expect(sut.searchQuery == "")
    }

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

    @Test("didAppear uses search use case when query is set")
    func didAppearUsesSearchUseCaseWhenQueryIsSet() async {
        // Given
        searchCharactersPageUseCaseMock.result = .success(.stub())
        sut.searchQuery = "Morty"
        await sut.searchTask?.value

        // When
        await sut.didAppear()

        // Then
        #expect(searchCharactersPageUseCaseMock.lastRequestedFilter?.name == "Morty")
        #expect(getCharactersPageUseCaseMock.executeCallCount == 0)
    }

    @Test("didTapOnLoadMoreButton uses search use case when query is set")
    func didTapOnLoadMoreButtonUsesSearchUseCaseWhenQueryIsSet() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        searchCharactersPageUseCaseMock.result = .success(firstPage)
        sut.searchQuery = "Summer"
        await sut.searchTask?.value
        await sut.didAppear()

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(searchCharactersPageUseCaseMock.lastRequestedFilter?.name == "Summer")
    }

    @Test("Empty search query uses get characters use case")
    func emptySearchQueryUsesGetCharactersPageUseCase() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didAppear()

        // Then
        #expect(getCharactersPageUseCaseMock.executeCallCount == 1)
        #expect(searchCharactersPageUseCaseMock.executeCallCount == 0)
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
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(currentPage: 2, hasNextPage: false)
        getCharactersPageUseCaseMock.result = .success(firstPage)
        await sut.didAppear()
        getCharactersPageUseCaseMock.result = .success(secondPage)
        await sut.didTapOnLoadMoreButton()

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

    @Test("didPullToRefresh calls refresh use case")
    func didPullToRefreshCallsRefreshUseCase() async {
        // Given
        refreshCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(refreshCharactersPageUseCaseMock.executeCallCount == 1)
    }

    @Test("didPullToRefresh resets to page one")
    func didPullToRefreshResetsToPageOne() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(currentPage: 2, hasNextPage: false)
        getCharactersPageUseCaseMock.result = .success(firstPage)
        await sut.didAppear()
        getCharactersPageUseCaseMock.result = .success(secondPage)
        await sut.didTapOnLoadMoreButton()
        refreshCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(refreshCharactersPageUseCaseMock.lastRequestedPage == 1)
    }

    @Test("didPullToRefresh keeps loaded state visible during network request")
    func didPullToRefreshKeepsLoadedStateDuringRequest() async {
        // Given
        let loadedPage = CharactersPage.stub()
        getCharactersPageUseCaseMock.result = .success(loadedPage)
        await sut.didAppear()
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
        #expect(statesDuringRefresh.first == .loaded(loadedPage))
    }

    @Test("didPullToRefresh sets empty state when no characters returned")
    func didPullToRefreshSetsEmptyStateWhenNoCharacters() async {
        // Given
        let emptyPage = CharactersPage.stub(characters: [])
        refreshCharactersPageUseCaseMock.result = .success(emptyPage)

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(sut.state == .empty)
    }

    @Test("didPullToRefresh sets error state on failure")
    func didPullToRefreshSetsErrorStateOnFailure() async {
        // Given
        refreshCharactersPageUseCaseMock.result = .failure(.loadFailed)

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    // MARK: - Tracking

    @Test("didAppear tracks screen viewed")
    func didAppearTracksScreenViewed() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
    }

    @Test("Selecting character tracks character selected with identifier")
    func didSelectTracksCharacterSelected() {
        // Given
        let character = Character.stub(id: 42)

        // When
        sut.didSelect(character)

        // Then
        #expect(trackerMock.selectedIdentifiers == [42])
    }

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

    @Test("didTapOnRetryButton tracks retry button tapped")
    func didTapOnRetryButtonTracksRetryButtonTapped() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didTapOnRetryButton()

        // Then
        #expect(trackerMock.retryButtonTappedCallCount == 1)
    }

    @Test("didPullToRefresh tracks pull to refresh triggered")
    func didPullToRefreshTracksPullToRefreshTriggered() async {
        // Given
        refreshCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(trackerMock.pullToRefreshTriggeredCallCount == 1)
    }

    @Test("didTapOnLoadMoreButton tracks load more button tapped")
    func didTapOnLoadMoreButtonTracksLoadMoreButtonTapped() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        getCharactersPageUseCaseMock.result = .success(firstPage)
        await sut.didAppear()

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(trackerMock.loadMoreButtonTappedCallCount == 1)
    }

    @Test("didTapOnLoadMoreButton does not track when no next page")
    func didTapOnLoadMoreButtonDoesNotTrackWhenNoNextPage() async {
        // Given
        let lastPage = CharactersPage.stub(hasNextPage: false)
        getCharactersPageUseCaseMock.result = .success(lastPage)
        await sut.didAppear()

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(trackerMock.loadMoreButtonTappedCallCount == 0)
    }

    // MARK: - Recent Searches

    @Test("Initial recentSearches is empty array")
    func initialRecentSearchesIsEmpty() {
        // Then
        #expect(sut.recentSearches == [])
    }

    @Test("didAppear loads recent searches")
    func didAppearLoadsRecentSearches() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())
        getRecentSearchesUseCaseMock.searches = ["Rick", "Morty"]

        // When
        await sut.didAppear()

        // Then
        #expect(sut.recentSearches == ["Rick", "Morty"])
    }

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

    @Test("didSelectRecentSearch sets searchQuery")
    func didSelectRecentSearchSetsSearchQuery() async {
        // Given
        searchCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didSelectRecentSearch("Rick")

        // Then
        #expect(sut.searchQuery == "Rick")
    }

    @Test("didSelectRecentSearch triggers immediate search")
    func didSelectRecentSearchTriggersImmediateSearch() async {
        // Given
        searchCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didSelectRecentSearch("Rick")

        // Then
        #expect(searchCharactersPageUseCaseMock.executeCallCount == 1)
        #expect(searchCharactersPageUseCaseMock.lastRequestedFilter?.name == "Rick")
    }

    @Test("didSelectRecentSearch saves the query")
    func didSelectRecentSearchSavesQuery() async {
        // Given
        searchCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didSelectRecentSearch("Morty")

        // Then
        #expect(saveRecentSearchUseCaseMock.savedQueries == ["Morty"])
    }

    @Test("didSelectRecentSearch tracks search performed")
    func didSelectRecentSearchTracksSearchPerformed() async {
        // Given
        searchCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didSelectRecentSearch("Summer")

        // Then
        #expect(trackerMock.searchedQueries == ["Summer"])
    }

    @Test("didDeleteRecentSearch calls delete use case with correct query")
    func didDeleteRecentSearchCallsDeleteUseCase() {
        // When
        sut.didDeleteRecentSearch("Rick")

        // Then
        #expect(deleteRecentSearchUseCaseMock.deletedQueries == ["Rick"])
    }

    @Test("didDeleteRecentSearch refreshes recent searches list")
    func didDeleteRecentSearchRefreshesList() {
        // Given
        getRecentSearchesUseCaseMock.searches = ["Morty"]

        // When
        sut.didDeleteRecentSearch("Rick")

        // Then
        #expect(sut.recentSearches == ["Morty"])
        #expect(getRecentSearchesUseCaseMock.executeCallCount >= 1)
    }

    // MARK: - Advanced Search

    @Test("didTapAdvancedSearchButton tracks event")
    func didTapAdvancedSearchButtonTracksEvent() {
        // When
        sut.didTapAdvancedSearchButton()

        // Then
        #expect(trackerMock.advancedSearchButtonTappedCallCount == 1)
    }

    @Test("didTapAdvancedSearchButton calls navigator")
    func didTapAdvancedSearchButtonCallsNavigator() {
        // When
        sut.didTapAdvancedSearchButton()

        // Then
        #expect(navigatorMock.presentAdvancedSearchCallCount == 1)
    }

    @Test("didChangeAdvancedFilters triggers fetch characters")
    func didChangeAdvancedFiltersTriggersFetchCharacters() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didChangeAdvancedFilters()

        // Then
        #expect(getCharactersPageUseCaseMock.executeCallCount == 1)
    }

    @Test("searchQuery reflects updated value")
    func searchQueryReflectsUpdatedValue() {
        // When
        sut.searchQuery = "Morty"

        // Then
        #expect(sut.searchQuery == "Morty")
    }

    @Test("searchQuery reflects cleared value")
    func searchQueryReflectsClearedValue() {
        // Given
        sut.searchQuery = "Morty"

        // When
        sut.searchQuery = ""

        // Then
        #expect(sut.searchQuery == "")
    }

    @Test("fetchCharacters uses search use case when filterState has active filters")
    func fetchCharactersUsesSearchUseCaseWhenFilterStateHasActiveFilters() async {
        // Given
        filterState.status = .alive
        searchCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didChangeAdvancedFilters()

        // Then
        #expect(searchCharactersPageUseCaseMock.executeCallCount == 1)
        #expect(searchCharactersPageUseCaseMock.lastRequestedFilter?.status == .alive)
        #expect(getCharactersPageUseCaseMock.executeCallCount == 0)
    }

    @Test("fetchMoreCharacters uses search use case when filterState has active filters")
    func fetchMoreCharactersUsesSearchUseCaseWhenFilterStateHasActiveFilters() async {
        // Given
        filterState.status = .dead
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        searchCharactersPageUseCaseMock.result = .success(firstPage)
        await sut.didChangeAdvancedFilters()

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(searchCharactersPageUseCaseMock.lastRequestedFilter?.status == .dead)
        #expect(searchCharactersPageUseCaseMock.lastRequestedPage == 2)
    }

    @Test("activeFilterCount reflects filterState")
    func activeFilterCountReflectsFilterState() {
        // Given
        filterState.status = .alive
        filterState.gender = .male

        // Then
        #expect(sut.activeFilterCount == 2)
    }

    @Test("advancedFilterSnapshot reflects filter state")
    func advancedFilterSnapshotReflectsFilterState() {
        // Given
        filterState.status = .alive
        filterState.species = "Human"

        // Then
        #expect(sut.advancedFilterSnapshot == filterState.filter)
    }

    @Test("fetchCharacters combines name and filter state")
    func fetchCharactersCombinesNameAndFilterState() async {
        // Given
        filterState.status = .alive
        searchCharactersPageUseCaseMock.result = .success(.stub())
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // Then
        let filter = searchCharactersPageUseCaseMock.lastRequestedFilter
        #expect(filter?.name == "Rick")
        #expect(filter?.status == .alive)
    }
}

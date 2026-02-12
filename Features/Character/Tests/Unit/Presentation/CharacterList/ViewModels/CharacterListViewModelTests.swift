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
        getCharactersPageUseCaseMock.result = .failure(.loadFailed())

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .error(.loadFailed()))
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
        getCharactersPageUseCaseMock.result = .failure(.loadFailed())
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
        getCharactersPageUseCaseMock.result = .failure(.loadFailed())

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
        getCharactersPageUseCaseMock.result = .failure(.loadFailed())
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
        refreshCharactersPageUseCaseMock.result = .failure(.loadFailed())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(sut.state == .error(.loadFailed()))
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

    // MARK: - Error Tracking

    @Test("didAppear tracks fetch error on failure")
    func didAppearTracksFetchErrorOnFailure() async {
        // Given
        getCharactersPageUseCaseMock.result = .failure(.loadFailed())

        // When
        await sut.didAppear()

        // Then
        #expect(trackerMock.fetchErrorDescriptions.count == 1)
        #expect(trackerMock.fetchErrorDescriptions.first == CharactersPageError.loadFailed().debugDescription)
    }

    @Test("didAppear does not track fetch error on success")
    func didAppearDoesNotTrackFetchErrorOnSuccess() async {
        // Given
        getCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didAppear()

        // Then
        #expect(trackerMock.fetchErrorDescriptions.isEmpty)
    }

    @Test("didPullToRefresh tracks refresh error on failure")
    func didPullToRefreshTracksRefreshErrorOnFailure() async {
        // Given
        refreshCharactersPageUseCaseMock.result = .failure(.loadFailed())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(trackerMock.refreshErrorDescriptions.count == 1)
        #expect(trackerMock.refreshErrorDescriptions.first == CharactersPageError.loadFailed().debugDescription)
    }

    @Test("didPullToRefresh does not track refresh error on success")
    func didPullToRefreshDoesNotTrackRefreshErrorOnSuccess() async {
        // Given
        refreshCharactersPageUseCaseMock.result = .success(.stub())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(trackerMock.refreshErrorDescriptions.isEmpty)
    }

    @Test("didTapOnLoadMoreButton tracks load more error on failure")
    func didTapOnLoadMoreButtonTracksLoadMoreErrorOnFailure() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        getCharactersPageUseCaseMock.result = .success(firstPage)
        await sut.didAppear()
        getCharactersPageUseCaseMock.result = .failure(.loadFailed())

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(trackerMock.loadMoreErrorDescriptions.count == 1)
        #expect(trackerMock.loadMoreErrorDescriptions.first == CharactersPageError.loadFailed().debugDescription)
    }

    @Test("didTapOnLoadMoreButton does not track load more error on success")
    func didTapOnLoadMoreButtonDoesNotTrackLoadMoreErrorOnSuccess() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        getCharactersPageUseCaseMock.result = .success(firstPage)
        await sut.didAppear()

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(trackerMock.loadMoreErrorDescriptions.isEmpty)
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
    func didDeleteRecentSearchCallsDeleteUseCase() async {
        // When
        await sut.didDeleteRecentSearch("Rick")

        // Then
        #expect(deleteRecentSearchUseCaseMock.deletedQueries == ["Rick"])
    }

    @Test("didDeleteRecentSearch refreshes recent searches list")
    func didDeleteRecentSearchRefreshesList() async {
        // Given
        getRecentSearchesUseCaseMock.searches = ["Morty"]

        // When
        await sut.didDeleteRecentSearch("Rick")

        // Then
        #expect(sut.recentSearches == ["Morty"])
        #expect(getRecentSearchesUseCaseMock.executeCallCount >= 1)
    }

    // MARK: - Character Filter

    @Test("didTapCharacterFilterButton tracks event")
    func didTapCharacterFilterButtonTracksEvent() {
        // When
        sut.didTapCharacterFilterButton()

        // Then
        #expect(trackerMock.characterFilterButtonTappedCallCount == 1)
    }

    @Test("didTapCharacterFilterButton calls navigator with self as delegate")
    func didTapCharacterFilterButtonCallsNavigator() {
        // When
        sut.didTapCharacterFilterButton()

        // Then
        #expect(navigatorMock.presentCharacterFilterCallCount == 1)
        #expect(navigatorMock.lastPresentCharacterFilterDelegate === sut)
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

    @Test("fetchMoreCharacters uses search use case when character filters are active")
    func fetchMoreCharactersUsesSearchUseCaseWhenCharacterFiltersAreActive() async {
        // Given
        let filter = CharacterFilter(status: .dead)
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        searchCharactersPageUseCaseMock.result = .success(firstPage)
        await sut.applyCharacterFilters(filter)

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(searchCharactersPageUseCaseMock.lastRequestedFilter?.status == .dead)
        #expect(searchCharactersPageUseCaseMock.lastRequestedPage == 2)
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

    @Test("fetchCharacters ignores error when search task is cancelled during network request")
    func fetchCharactersIgnoresErrorDuringCancelledSearch() async {
        // Given
        let page = CharactersPage.stub()
        getCharactersPageUseCaseMock.result = .success(page)
        await sut.didAppear()
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
        #expect(sut.state == .loaded(page))
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


}

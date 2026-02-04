import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterListViewModelTests {
    // MARK: - Properties

    private let getCharactersUseCaseMock = GetCharactersUseCaseMock()
    private let refreshCharactersUseCaseMock = RefreshCharactersUseCaseMock()
    private let searchCharactersUseCaseMock = SearchCharactersUseCaseMock()
    private let navigatorMock = CharacterListNavigatorMock()
    private let trackerMock = CharacterListTrackerMock()
    private let sut: CharacterListViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterListViewModel(
            getCharactersUseCase: getCharactersUseCaseMock,
            refreshCharactersUseCase: refreshCharactersUseCaseMock,
            searchCharactersUseCase: searchCharactersUseCaseMock,
            navigator: navigatorMock,
            tracker: trackerMock
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
        getCharactersUseCaseMock.result = .success(expected)

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("didAppear sets empty state when no characters returned")
    func didAppearSetsEmptyStateWhenNoCharacters() async {
        // Given
        let emptyPage = CharactersPage.stub(characters: [])
        getCharactersUseCaseMock.result = .success(emptyPage)

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .empty)
    }

    @Test("didAppear sets error state on failure")
    func didAppearSetsErrorStateOnFailure() async {
        // Given
        getCharactersUseCaseMock.result = .failure(.loadFailed)

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test("didAppear calls use case requesting page one")
    func didAppearCallsUseCaseWithPageOne() async {
        // Given
        getCharactersUseCaseMock.result = .success(.stub())

        // When
        await sut.didAppear()

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == 1)
        #expect(getCharactersUseCaseMock.lastRequestedPage == 1)
    }

    @Test("didAppear does nothing when already loaded")
    func didAppearDoesNothingWhenLoaded() async {
        // Given
        getCharactersUseCaseMock.result = .success(.stub())
        await sut.didAppear()

        // When
        await sut.didAppear()

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == 1)
    }

    @Test("didAppear does nothing when empty state")
    func didAppearDoesNothingWhenEmpty() async {
        // Given
        let emptyPage = CharactersPage.stub(characters: [])
        getCharactersUseCaseMock.result = .success(emptyPage)
        await sut.didAppear()

        // When
        await sut.didAppear()

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == 1)
    }

    @Test("didAppear does nothing when in error state")
    func didAppearDoesNothingWhenError() async {
        // Given
        getCharactersUseCaseMock.result = .failure(.loadFailed)
        await sut.didAppear()

        // When
        await sut.didAppear()

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == 1)
    }

    // MARK: - didTapOnRetryButton

    @Test("didTapOnRetryButton retries loading when in error state")
    func didTapOnRetryButtonRetriesWhenError() async {
        // Given
        getCharactersUseCaseMock.result = .failure(.loadFailed)
        await sut.didAppear()

        // When
        getCharactersUseCaseMock.result = .success(.stub())
        await sut.didTapOnRetryButton()

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == 2)
    }

    @Test("didTapOnRetryButton always loads regardless of current state")
    func didTapOnRetryButtonAlwaysLoads() async {
        // Given
        getCharactersUseCaseMock.result = .success(.stub())
        await sut.didAppear()
        #expect(getCharactersUseCaseMock.executeCallCount == 1)

        // When
        await sut.didTapOnRetryButton()

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == 2)
    }

    // MARK: - didTapOnLoadMoreButton

    @Test("didTapOnLoadMoreButton appends new characters to existing list")
    func didTapOnLoadMoreButtonAppendsCharactersToExistingPage() async {
        // Given
        let firstPageCharacters = [Character.stub(id: 1)]
        let secondPageCharacters = [Character.stub(id: 2)]
        let firstPage = CharactersPage.stub(characters: firstPageCharacters, currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(characters: secondPageCharacters, currentPage: 2, hasNextPage: false)
        getCharactersUseCaseMock.result = .success(firstPage)
        await sut.didAppear()
        getCharactersUseCaseMock.result = .success(secondPage)

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
        getCharactersUseCaseMock.result = .success(firstPage)
        await sut.didAppear()

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(getCharactersUseCaseMock.lastRequestedPage == 2)
    }

    @Test("didTapOnLoadMoreButton does nothing when no next page available")
    func didTapOnLoadMoreButtonDoesNothingWhenNoNextPage() async {
        // Given
        let lastPage = CharactersPage.stub(hasNextPage: false)
        getCharactersUseCaseMock.result = .success(lastPage)
        await sut.didAppear()

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == 1)
    }

    @Test("didTapOnLoadMoreButton keeps existing data on error")
    func didTapOnLoadMoreButtonKeepsExistingDataOnError() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        getCharactersUseCaseMock.result = .success(firstPage)
        await sut.didAppear()
        getCharactersUseCaseMock.result = .failure(.loadFailed)

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(sut.state == .loaded(firstPage))
    }

    @Test("didTapOnLoadMoreButton reverts page number on error for retry")
    func didTapOnLoadMoreButtonRevertsPageOnError() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        getCharactersUseCaseMock.result = .success(firstPage)
        await sut.didAppear()
        getCharactersUseCaseMock.result = .failure(.loadFailed)
        await sut.didTapOnLoadMoreButton()

        // When - retry after error
        getCharactersUseCaseMock.result = .success(CharactersPage.stub(currentPage: 2))
        await sut.didTapOnLoadMoreButton()

        // Then - should request page 2 again, not page 3
        #expect(getCharactersUseCaseMock.lastRequestedPage == 2)
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

    @Test("Initial search query is empty string")
    func initialSearchQueryIsEmpty() {
        // Then
        #expect(sut.searchQuery == "")
    }

    @Test("Search query change triggers search use case after debounce delay")
    func searchQueryChangeTriggersSearchAfterDebounce() async throws {
        // Given
        searchCharactersUseCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(searchCharactersUseCaseMock.lastRequestedQuery == "Rick")
    }

    @Test("Rapid search query changes only trigger one load")
    func rapidSearchQueryChangesOnlyTriggersOneLoad() async throws {
        // Given
        searchCharactersUseCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "R"
        try await Task.sleep(for: .milliseconds(100))
        sut.searchQuery = "Ri"
        try await Task.sleep(for: .milliseconds(100))
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(searchCharactersUseCaseMock.executeCallCount == 1)
        #expect(searchCharactersUseCaseMock.lastRequestedQuery == "Rick")
    }

    @Test("didAppear uses search use case when query is set")
    func didAppearUsesSearchUseCaseWhenQueryIsSet() async {
        // Given
        searchCharactersUseCaseMock.result = .success(.stub())
        sut.searchQuery = "Morty"

        // When
        await sut.didAppear()

        // Then
        #expect(searchCharactersUseCaseMock.lastRequestedQuery == "Morty")
        #expect(getCharactersUseCaseMock.executeCallCount == 0)
    }

    @Test("didTapOnLoadMoreButton uses search use case when query is set")
    func didTapOnLoadMoreButtonUsesSearchUseCaseWhenQueryIsSet() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        searchCharactersUseCaseMock.result = .success(firstPage)
        sut.searchQuery = "Summer"
        await sut.didAppear()

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(searchCharactersUseCaseMock.lastRequestedQuery == "Summer")
    }

    @Test("Empty search query uses get characters use case")
    func emptySearchQueryUsesGetCharactersUseCase() async {
        // Given
        getCharactersUseCaseMock.result = .success(.stub())
        sut.searchQuery = ""

        // When
        await sut.didAppear()

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == 1)
        #expect(searchCharactersUseCaseMock.executeCallCount == 0)
    }

    @Test("Whitespace-only search query uses get characters use case")
    func whitespaceOnlySearchQueryUsesGetCharactersUseCase() async {
        // Given
        getCharactersUseCaseMock.result = .success(.stub())
        sut.searchQuery = "   "

        // When
        await sut.didAppear()

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == 1)
        #expect(searchCharactersUseCaseMock.executeCallCount == 0)
    }

    @Test("Search query change resets to page one")
    func searchQueryChangeResetsToPageOne() async throws {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(currentPage: 2, hasNextPage: false)
        getCharactersUseCaseMock.result = .success(firstPage)
        await sut.didAppear()
        getCharactersUseCaseMock.result = .success(secondPage)
        await sut.didTapOnLoadMoreButton()

        // When
        searchCharactersUseCaseMock.result = .success(.stub())
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(searchCharactersUseCaseMock.lastRequestedPage == 1)
    }

    @Test("Search with no results sets emptySearch state")
    func searchWithNoResultsSetsEmptySearchState() async throws {
        // Given
        let emptyPage = CharactersPage.stub(characters: [])
        searchCharactersUseCaseMock.result = .success(emptyPage)

        // When
        sut.searchQuery = "NonExistent"
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(sut.state == .emptySearch)
    }

    @Test("Clearing search query before debounce only triggers one load")
    func clearingSearchQueryBeforeDebounceOnlyTriggersOneLoad() async throws {
        // Given
        getCharactersUseCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(100))
        sut.searchQuery = ""
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == 1)
        #expect(searchCharactersUseCaseMock.executeCallCount == 0)
    }

    // MARK: - didPullToRefresh

    @Test("didPullToRefresh calls refresh use case")
    func didPullToRefreshCallsRefreshUseCase() async {
        // Given
        refreshCharactersUseCaseMock.result = .success(.stub())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(refreshCharactersUseCaseMock.executeCallCount == 1)
    }

    @Test("didPullToRefresh resets to page one")
    func didPullToRefreshResetsToPageOne() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(currentPage: 2, hasNextPage: false)
        getCharactersUseCaseMock.result = .success(firstPage)
        await sut.didAppear()
        getCharactersUseCaseMock.result = .success(secondPage)
        await sut.didTapOnLoadMoreButton()
        refreshCharactersUseCaseMock.result = .success(.stub())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(refreshCharactersUseCaseMock.lastRequestedPage == 1)
    }

    @Test("didPullToRefresh keeps loaded state visible during network request")
    func didPullToRefreshKeepsLoadedStateDuringRequest() async {
        // Given
        let loadedPage = CharactersPage.stub()
        getCharactersUseCaseMock.result = .success(loadedPage)
        await sut.didAppear()
        refreshCharactersUseCaseMock.result = .success(.stub())

        var statesDuringRefresh: [CharacterListViewState] = []
        refreshCharactersUseCaseMock.onExecute = { [weak sut] in
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
        refreshCharactersUseCaseMock.result = .success(emptyPage)

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(sut.state == .empty)
    }

    @Test("didPullToRefresh sets error state on failure")
    func didPullToRefreshSetsErrorStateOnFailure() async {
        // Given
        refreshCharactersUseCaseMock.result = .failure(.loadFailed)

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    // MARK: - Tracking

    @Test("didAppear tracks screen viewed")
    func didAppearTracksScreenViewed() async {
        // Given
        getCharactersUseCaseMock.result = .success(.stub())

        // When
        await sut.didAppear()

        // Then
        #expect(trackerMock.screenViewedCallCount == 1)
    }

    @Test("didAppear does not track screen viewed when already loaded")
    func didAppearDoesNotTrackScreenViewedWhenAlreadyLoaded() async {
        // Given
        getCharactersUseCaseMock.result = .success(.stub())
        await sut.didAppear()

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
    func searchQueryChangeTracksSearchPerformed() async throws {
        // Given
        searchCharactersUseCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(trackerMock.searchedQueries == ["Rick"])
    }

    @Test("Empty search query does not track search performed")
    func emptySearchQueryDoesNotTrackSearchPerformed() async throws {
        // Given
        getCharactersUseCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(100))
        sut.searchQuery = ""
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(trackerMock.searchedQueries.isEmpty)
    }

    @Test("didTapOnRetryButton tracks retry button tapped")
    func didTapOnRetryButtonTracksRetryButtonTapped() async {
        // Given
        getCharactersUseCaseMock.result = .success(.stub())

        // When
        await sut.didTapOnRetryButton()

        // Then
        #expect(trackerMock.retryButtonTappedCallCount == 1)
    }

    @Test("didPullToRefresh tracks pull to refresh triggered")
    func didPullToRefreshTracksPullToRefreshTriggered() async {
        // Given
        refreshCharactersUseCaseMock.result = .success(.stub())

        // When
        await sut.didPullToRefresh()

        // Then
        #expect(trackerMock.pullToRefreshTriggeredCallCount == 1)
    }

    @Test("didTapOnLoadMoreButton tracks load more button tapped")
    func didTapOnLoadMoreButtonTracksLoadMoreButtonTapped() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        getCharactersUseCaseMock.result = .success(firstPage)
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
        getCharactersUseCaseMock.result = .success(lastPage)
        await sut.didAppear()

        // When
        await sut.didTapOnLoadMoreButton()

        // Then
        #expect(trackerMock.loadMoreButtonTappedCallCount == 0)
    }
}

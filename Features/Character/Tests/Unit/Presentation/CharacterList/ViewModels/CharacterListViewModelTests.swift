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
    private let sut: CharacterListViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterListViewModel(
            getCharactersUseCase: getCharactersUseCaseMock,
            refreshCharactersUseCase: refreshCharactersUseCaseMock,
            searchCharactersUseCase: searchCharactersUseCaseMock,
            navigator: navigatorMock
        )
    }

    // MARK: - Initial State

    @Test("Initial state is idle before loading")
    func initialStateIsIdle() {
        // Then
        #expect(sut.state == .idle)
    }

    // MARK: - Load

    @Test("Load sets loaded state with characters on success")
    func loadSetsLoadedStateOnSuccess() async {
        // Given
        let expected = CharactersPage.stub()
        getCharactersUseCaseMock.result = .success(expected)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("Load sets empty state when no characters returned")
    func loadSetsEmptyStateWhenNoCharacters() async {
        // Given
        let emptyPage = CharactersPage.stub(characters: [])
        getCharactersUseCaseMock.result = .success(emptyPage)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .empty)
    }

    @Test("Load sets error state on failure")
    func loadSetsErrorStateOnFailure() async {
        // Given
        getCharactersUseCaseMock.result = .failure(.loadFailed)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test("Load calls use case requesting page one")
    func loadCallsUseCaseWithPageOne() async {
        // Given
        getCharactersUseCaseMock.result = .success(.stub())

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == 1)
        #expect(getCharactersUseCaseMock.lastRequestedPage == 1)
    }

    @Test("Load if needed does nothing when already loaded")
    func loadIfNeededDoesNothingWhenLoaded() async {
        // Given
        getCharactersUseCaseMock.result = .success(.stub())
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = getCharactersUseCaseMock.executeCallCount

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == callCountAfterFirstLoad)
    }

    @Test("Load if needed does nothing when empty state")
    func loadIfNeededDoesNothingWhenEmpty() async {
        // Given
        let emptyPage = CharactersPage.stub(characters: [])
        getCharactersUseCaseMock.result = .success(emptyPage)
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = getCharactersUseCaseMock.executeCallCount

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == callCountAfterFirstLoad)
    }

    @Test("Load if needed retries when in error state")
    func loadIfNeededLoadsWhenError() async {
        // Given
        getCharactersUseCaseMock.result = .failure(.loadFailed)
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = getCharactersUseCaseMock.executeCallCount

        // When
        getCharactersUseCaseMock.result = .success(.stub())
        await sut.loadIfNeeded()

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == callCountAfterFirstLoad + 1)
    }

    // MARK: - Load More

    @Test("Load more appends new characters to existing list")
    func loadMoreAppendsCharactersToExistingPage() async {
        // Given
        let firstPageCharacters = [Character.stub(id: 1)]
        let secondPageCharacters = [Character.stub(id: 2)]
        let firstPage = CharactersPage.stub(characters: firstPageCharacters, currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(characters: secondPageCharacters, currentPage: 2, hasNextPage: false)
        getCharactersUseCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()
        getCharactersUseCaseMock.result = .success(secondPage)

        // When
        await sut.loadMore()

        // Then
        let expected = CharactersPage.stub(
            characters: [Character.stub(id: 1), Character.stub(id: 2)],
            currentPage: 2,
            hasNextPage: false,
            hasPreviousPage: false
        )
        #expect(sut.state == .loaded(expected))
    }

    @Test("Load more increments page number")
    func loadMoreIncrementsPage() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        getCharactersUseCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()

        // When
        await sut.loadMore()

        // Then
        #expect(getCharactersUseCaseMock.lastRequestedPage == 2)
    }

    @Test("Load more does nothing when no next page available")
    func loadMoreDoesNothingWhenNoNextPage() async {
        // Given
        let lastPage = CharactersPage.stub(hasNextPage: false)
        getCharactersUseCaseMock.result = .success(lastPage)
        await sut.loadIfNeeded()
        let callCountAfterLoad = getCharactersUseCaseMock.executeCallCount

        // When
        await sut.loadMore()

        // Then
        #expect(getCharactersUseCaseMock.executeCallCount == callCountAfterLoad)
    }

    @Test("Load more keeps existing data on error")
    func loadMoreKeepsExistingDataOnError() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        getCharactersUseCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()
        getCharactersUseCaseMock.result = .failure(.loadFailed)

        // When
        await sut.loadMore()

        // Then
        #expect(sut.state == .loaded(firstPage))
    }

    @Test("Load more reverts page number on error for retry")
    func loadMoreRevertsPageOnError() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        getCharactersUseCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()
        getCharactersUseCaseMock.result = .failure(.loadFailed)
        await sut.loadMore()

        // When - retry after error
        getCharactersUseCaseMock.result = .success(CharactersPage.stub(currentPage: 2))
        await sut.loadMore()

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

    @Test("Load uses search use case when query is set")
    func loadUsesSearchUseCaseWhenQueryIsSet() async {
        // Given
        searchCharactersUseCaseMock.result = .success(.stub())
        sut.searchQuery = "Morty"

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(searchCharactersUseCaseMock.lastRequestedQuery == "Morty")
        #expect(getCharactersUseCaseMock.executeCallCount == 0)
    }

    @Test("Load more uses search use case when query is set")
    func loadMoreUsesSearchUseCaseWhenQueryIsSet() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        searchCharactersUseCaseMock.result = .success(firstPage)
        sut.searchQuery = "Summer"
        await sut.loadIfNeeded()

        // When
        await sut.loadMore()

        // Then
        #expect(searchCharactersUseCaseMock.lastRequestedQuery == "Summer")
    }

    @Test("Empty search query uses get characters use case")
    func emptySearchQueryUsesGetCharactersUseCase() async {
        // Given
        getCharactersUseCaseMock.result = .success(.stub())
        sut.searchQuery = ""

        // When
        await sut.loadIfNeeded()

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
        await sut.loadIfNeeded()

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
        await sut.loadIfNeeded()
        getCharactersUseCaseMock.result = .success(secondPage)
        await sut.loadMore()

        // When
        searchCharactersUseCaseMock.result = .success(.stub())
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(searchCharactersUseCaseMock.lastRequestedPage == 1)
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

    // MARK: - Refresh

    @Test("Refresh calls refresh use case")
    func refreshCallsRefreshUseCase() async {
        // Given
        refreshCharactersUseCaseMock.result = .success(.stub())

        // When
        await sut.refresh()

        // Then
        #expect(refreshCharactersUseCaseMock.executeCallCount == 1)
    }

    @Test("Refresh resets to page one")
    func refreshResetsToPageOne() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(currentPage: 2, hasNextPage: false)
        getCharactersUseCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()
        getCharactersUseCaseMock.result = .success(secondPage)
        await sut.loadMore()
        refreshCharactersUseCaseMock.result = .success(.stub())

        // When
        await sut.refresh()

        // Then
        #expect(refreshCharactersUseCaseMock.lastRequestedPage == 1)
    }
}

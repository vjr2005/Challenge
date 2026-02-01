import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterListViewModelTests {
    // MARK: - Properties

    private let useCaseMock = GetCharactersUseCaseMock()
    private let clearCacheMock = ClearCharactersCacheUseCaseMock()
    private let navigatorMock = CharacterListNavigatorMock()
    private let sut: CharacterListViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterListViewModel(
            getCharactersUseCase: useCaseMock,
            clearCacheUseCase: clearCacheMock,
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
        useCaseMock.result = .success(expected)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("Load sets empty state when no characters returned")
    func loadSetsEmptyStateWhenNoCharacters() async {
        // Given
        let emptyPage = CharactersPage.stub(characters: [])
        useCaseMock.result = .success(emptyPage)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .empty)
    }

    @Test("Load sets error state on failure")
    func loadSetsErrorStateOnFailure() async {
        // Given
        useCaseMock.result = .failure(.loadFailed)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test("Load calls use case requesting page one")
    func loadCallsUseCaseWithPageOne() async {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == 1)
        #expect(useCaseMock.lastRequestedPage == 1)
    }

    @Test("Load if needed does nothing when already loaded")
    func loadIfNeededDoesNothingWhenLoaded() async {
        // Given
        useCaseMock.result = .success(.stub())
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = useCaseMock.executeCallCount

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == callCountAfterFirstLoad)
    }

    @Test("Load if needed does nothing when empty state")
    func loadIfNeededDoesNothingWhenEmpty() async {
        // Given
        let emptyPage = CharactersPage.stub(characters: [])
        useCaseMock.result = .success(emptyPage)
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = useCaseMock.executeCallCount

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == callCountAfterFirstLoad)
    }

    @Test("Load if needed retries when in error state")
    func loadIfNeededLoadsWhenError() async {
        // Given
        useCaseMock.result = .failure(.loadFailed)
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = useCaseMock.executeCallCount

        // When
        useCaseMock.result = .success(.stub())
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == callCountAfterFirstLoad + 1)
    }

    // MARK: - Load More

    @Test("Load more appends new characters to existing list")
    func loadMoreAppendsCharactersToExistingPage() async {
        // Given
        let firstPageCharacters = [Character.stub(id: 1)]
        let secondPageCharacters = [Character.stub(id: 2)]
        let firstPage = CharactersPage.stub(characters: firstPageCharacters, currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(characters: secondPageCharacters, currentPage: 2, hasNextPage: false)
        useCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()
        useCaseMock.result = .success(secondPage)

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
        useCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()

        // When
        await sut.loadMore()

        // Then
        #expect(useCaseMock.lastRequestedPage == 2)
    }

    @Test("Load more does nothing when no next page available")
    func loadMoreDoesNothingWhenNoNextPage() async {
        // Given
        let lastPage = CharactersPage.stub(hasNextPage: false)
        useCaseMock.result = .success(lastPage)
        await sut.loadIfNeeded()
        let callCountAfterLoad = useCaseMock.executeCallCount

        // When
        await sut.loadMore()

        // Then
        #expect(useCaseMock.executeCallCount == callCountAfterLoad)
    }

    @Test("Load more keeps existing data on error")
    func loadMoreKeepsExistingDataOnError() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        useCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()
        useCaseMock.result = .failure(.loadFailed)

        // When
        await sut.loadMore()

        // Then
        #expect(sut.state == .loaded(firstPage))
    }

    @Test("Load more reverts page number on error for retry")
    func loadMoreRevertsPageOnError() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        useCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()
        useCaseMock.result = .failure(.loadFailed)
        await sut.loadMore()

        // When - retry after error
        useCaseMock.result = .success(CharactersPage.stub(currentPage: 2))
        await sut.loadMore()

        // Then - should request page 2 again, not page 3
        #expect(useCaseMock.lastRequestedPage == 2)
    }

    // MARK: - Navigation

    @Test("Selecting character navigates to detail screen")
    func didSelectNavigatesToCharacterDetail() {
        // Given
        let character = Character.stub(id: 42)

        // When
        sut.didSelect(character)

        // Then
        #expect(navigatorMock.navigateToDetailIds == [42])
    }

    // MARK: - Search

    @Test("Initial search query is empty string")
    func initialSearchQueryIsEmpty() {
        // Then
        #expect(sut.searchQuery == "")
    }

    @Test("Search query change triggers load after debounce delay")
    func searchQueryChangeTriggersLoadAfterDebounce() async throws {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(useCaseMock.lastRequestedQuery == "Rick")
    }

    @Test("Rapid search query changes only trigger one load")
    func rapidSearchQueryChangesOnlyTriggersOneLoad() async throws {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "R"
        try await Task.sleep(for: .milliseconds(100))
        sut.searchQuery = "Ri"
        try await Task.sleep(for: .milliseconds(100))
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(useCaseMock.executeCallCount == 1)
        #expect(useCaseMock.lastRequestedQuery == "Rick")
    }

    @Test("Load uses current search query value")
    func loadUsesCurrentSearchQuery() async {
        // Given
        useCaseMock.result = .success(.stub())
        sut.searchQuery = "Morty"

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.lastRequestedQuery == "Morty")
    }

    @Test("Load more uses current search query value")
    func loadMoreUsesCurrentSearchQuery() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        useCaseMock.result = .success(firstPage)
        sut.searchQuery = "Summer"
        await sut.loadIfNeeded()

        // When
        await sut.loadMore()

        // Then
        #expect(useCaseMock.lastRequestedQuery == "Summer")
    }

    @Test("Empty search query passes nil to use case")
    func emptySearchQueryPassesNilToUseCase() async {
        // Given
        useCaseMock.result = .success(.stub())
        sut.searchQuery = ""

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.lastRequestedQuery == nil)
    }

    @Test("Whitespace-only search query passes nil to use case")
    func whitespaceOnlySearchQueryPassesNilToUseCase() async {
        // Given
        useCaseMock.result = .success(.stub())
        sut.searchQuery = "   "

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.lastRequestedQuery == nil)
    }

    @Test("Search query change resets to page one")
    func searchQueryChangeResetsToPageOne() async throws {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(currentPage: 2, hasNextPage: false)
        useCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()
        useCaseMock.result = .success(secondPage)
        await sut.loadMore()

        // When
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(useCaseMock.lastRequestedPage == 1)
    }

    @Test("Clearing search query before debounce only triggers one load")
    func clearingSearchQueryBeforeDebounceOnlyTriggersOneLoad() async throws {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(100))
        sut.searchQuery = ""
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(useCaseMock.executeCallCount == 1)
        #expect(useCaseMock.lastRequestedQuery == nil)
    }

    // MARK: - Refresh

    @Test("Refresh clears cache and reloads data")
    func refreshClearsCacheAndReloads() async {
        // Given
        useCaseMock.result = .success(.stub())
        await sut.loadIfNeeded()
        let callCountAfterLoad = useCaseMock.executeCallCount

        // When
        await sut.refresh()

        // Then
        #expect(clearCacheMock.executeCallCount == 1)
        #expect(useCaseMock.executeCallCount == callCountAfterLoad + 1)
    }

    @Test("Refresh resets to page one")
    func refreshResetsToPageOne() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(currentPage: 2, hasNextPage: false)
        useCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()
        useCaseMock.result = .success(secondPage)
        await sut.loadMore()

        // When
        await sut.refresh()

        // Then
        #expect(useCaseMock.lastRequestedPage == 1)
    }
}
